############################################################
#                                                          #
#                          hprose                          #
#                                                          #
# Official WebSite: http://www.hprose.com/                 #
#                   http://www.hprose.net/                 #
#                   http://www.hprose.org/                 #
#                                                          #
############################################################

############################################################
#                                                          #
# hprose/io.pm                                             #
#                                                          #
# hprose io for perl                                       #
#                                                          #
# LastModified: May 16, 2010                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

use Hprose::Common;
use strict;
use warnings;
use Encode;
use Error qw(:try);

package HproseTags;

# Serialize Tags #
use constant {
    TagInteger => 'i',
    TagLong => 'l',
    TagDouble => 'd',
    TagNull => 'n',
    TagEmpty => 'e',
    TagTrue => 't',
    TagFalse => 'f',
    TagNaN => 'N',
    TagInfinity => 'I',
    TagDate => 'D',
    TagTime => 'T',
    TagUTC => 'Z',
    TagBytes => 'b',
    TagUTF8Char => 'u',
    TagString => 's',
    TagList => 'a',
    TagMap => 'm',
    TagClass => 'c',
    TagObject => 'o',
    TagRef => 'r',
};

# Serialize Marks #
use constant {
    TagPos => '+',
    TagNeg => '-',
    TagSemicolon => ';',
    TagOpenbrace => '{',
    TagClosebrace => '}',
    TagQuote => '"',
    TagPoint => '.',
};

# Protocol Tags #
use constant {
    TagFunctions => 'F',
    TagCall => 'C',
    TagResult => 'R',
    TagArgument => 'A',
    TagError => 'E',
    TagEnd => 'z',
};

package HproseReader;

sub new {
    my $class = shift;
    my ($stream) = @_;
    my $self = bless {
        'stream' => $stream,
        'classref' => [],
        'ref' => [],
    }, $class;
}

package HproseWriter;

sub new {
    my $class = shift;
    my ($stream) = @_;
    my $self = bless {
        'stream' => $stream,
        'classref' => {},
        'ref' => {},
    }, $class;
}

sub serialize {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    if (!defined($val)) {
        $stream->write(HproseTags->TagNull, 1);
    }
    elsif (!ref($val)) {
        if ($val =~ /^-?(?:[0-9]|[1-9]\d+)$/) {
            if ($val >= -2147483648 && $val <= 2147483647) {
                $self->writeInt($val);
            }
            else {
                $self->writeLong($val);
            }
        }
        elsif ($val =~ /^-?(?:[0-9]|[1-9]\d+)(?:\.\d*)*(?:[e|E][-|+]?\d+)*$/) {
            $self->writeDouble($val);
        }
        elsif ($val =~ /^nan$/i) {
            $stream->write(HproseTags->TagNaN, 1);
        }
        elsif ($val =~ /^\+?inf$/i) {
            $stream->write(HproseTags->TagInfinity, 1);
            $stream->write(HproseTags->TagPos, 1);
        }
        elsif ($val =~ /^-inf$/i) {
            $stream->write(HproseTags->TagInfinity, 1);
            $stream->write(HproseTags->TagNeg, 1);
        }
        elsif ($val eq '') {
            $stream->write(HproseTags->TagEmpty, 1);
        }
        elsif (Encode::is_utf8($val)) {
            if (length($val) == 1) {
                $stream->write(HproseTags->TagUTF8Char, 1);
                Encode::_utf8_off($val);
                $stream->write($val, length($val));
                Encode::_utf8_on($val);
            }
            else {
                $self->writeString($val, 1);
            }
        }
        else {
            Encode::_utf8_on($val);
            if (Encode::is_utf8($val, 1)) {
                if (length($val) == 1) {
                    $stream->write(HproseTags->TagUTF8Char, 1);
                    Encode::_utf8_off($val);
                    $stream->write($val, length($val));
                }
                else {
                    $self->writeString($val);
                }
            }
            else {
                Encode::_utf8_off($val);
                $self->writeBytes($val);
            }
        }
    }
    else {
        my $type = ref($val);
        if ($type eq 'SCALAR' ||
            $type eq 'VSTRING' ||
            $type eq 'REF') {
            $self->serialize($$val);
        }
        elsif ($type eq 'ARRAY') {
            $self->writeArray($val);
        }
        elsif ($type eq 'HASH') {
            $self->writeHash($val);
        }
        elsif ($type eq 'CODE' ||
               $type eq 'GLOB' ||
               $type eq 'LVALUE' ||
               $type eq 'FORMAT' ||
               $type eq 'IO' ||
               $type eq 'Regexp') {
            throw HproseException('Not support to serialize this type: '. $type);
        }
        elsif ($type eq 'Math::BigInt') {
            $self->writeLong($val);
        }
        elsif ($type eq 'Math::BigFloat') {
            $self->writeDouble($val);
        }
        elsif ($type eq 'DateTime') {
            $self->writeDate($val);
        }
        else {
            $self->writeObject($val);
        }
    }
}

sub writeInt {
    my $self = shift;
    my ($val) = @_;
    $val = int($val);
    my $stream = $self->{'stream'};
    if ($val >= 0 && $val <= 9) {
        return $stream->write($val, 1);
    }
    else {
        $stream->write(HproseTags->TagInteger, 1);
        $stream->write($val, length($val));
        $stream->write(HproseTags->TagSemicolon, 1);
    }
}

sub writeLong {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagLong, 1);
    $stream->write($val, length($val));
    $stream->write(HproseTags->TagSemicolon, 1);
}

sub writeDouble {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagDouble, 1);
    $stream->write($val, length($val));
    $stream->write(HproseTags->TagSemicolon, 1);
}

sub writeNull {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagNull, 1);
}

sub writeNaN {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagNaN, 1);
}

sub writePosInf {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagInfinity, 1);
    $stream->write(HproseTags->TagPos, 1);
}

sub writeNegInf {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagInfinity, 1);
    $stream->write(HproseTags->TagNeg, 1);
}

sub writeBoolean {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    $stream->write($val ? HproseTags->TagTrue : HproseTags->TagFalse, 1);
}

sub writeEmpty {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagEmpty, 1);
}

sub writeString {
    my $self = shift;
    my ($val, $utf8, $checkRef) = @_;
    $checkRef = 1 if (!defined($checkRef));
    my $ref = $self->{'ref'};
    return $self->writeRef($ref->{$val}) if ($checkRef && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagString, 1);
    my $length = length($val);
    $stream->write($length, length($length)) if ($length > 0);
    $stream->write(HproseTags->TagQuote, 1);
    Encode::_utf8_off($val);
    $stream->write($val, length($val));
    Encode::_utf8_on($val) if ($utf8);
    $stream->write(HproseTags->TagQuote, 1);
}

sub writeBytes {
    my $self = shift;
    my ($val, $checkRef) = @_;
    $checkRef = 1 if (!defined($checkRef));
    my $ref = $self->{'ref'};
    return $self->writeRef($ref->{$val}) if ($checkRef && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagBytes, 1);
    my $length = length($val);
    $stream->write($length, length($length)) if ($length > 0);
    $stream->write(HproseTags->TagQuote, 1);
    $stream->write($val, length($val));
    $stream->write(HproseTags->TagQuote, 1);
}

sub _writeNanosecond {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    if ($val->nanosecond > 0) {
        $stream->write(HproseTags->TagPoint, 1);
        if ($val->microsecond * 1000 == $val->nanosecond) {
            if ($val->millisecond * 1000 == $val->microsecond) {
                $stream->write($val->strftime('%3N'), 3);
            }
            else {
                $stream->write($val->strftime('%6N'), 6);
            }
        }
        else {
            $stream->write($val->strftime('%9N'), 9);
        }
    }
}

sub _writeTimeZone {
    my $self = shift;
    my ($val, $utc, $time_zone) = @_;
    my $stream = $self->{'stream'};
    if ($utc) {
        $stream->write(HproseTags->TagUTC, 1);
        $val->set_time_zone($time_zone);
    }
    else {
        $stream->write(HproseTags->TagSemicolon, 1);
    }
}

sub writeDate {
    my $self = shift;
    my ($val, $checkRef) = @_;
    $checkRef = 1 if (!defined($checkRef));
    my $ref = $self->{'ref'};
    return $self->writeRef($ref->{$val}) if ($checkRef && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    my $time_zone = $val->time_zone;
    my $utc = ref($time_zone) ne 'DateTime::TimeZone::Floating';
    $val->set_time_zone('UTC') if ($utc);
    if ($val->hour == 0 &&
        $val->minute == 0 &&
        $val->second == 0 &&
        $val->nanosecond == 0) {
        $stream->write(HproseTags->TagDate, 1);
        $stream->write($val->ymd(''), 8);
        $self->_writeTimeZone($val, $utc, $time_zone);
    }
    elsif ($val->year == 1970 &&
           $val->month == 1 &&
           $val->day == 1) {
        $stream->write(HproseTags->TagTime, 1);
        $stream->write($val->hms(''), 6);
        $self->_writeNanosecond($val);
        $self->_writeTimeZone($val, $utc, $time_zone);
    }
    else {
        $stream->write(HproseTags->TagDate, 1);
        $stream->write($val->ymd(''), 8);
        $stream->write(HproseTags->TagTime, 1);
        $stream->write($val->hms(''), 6);
        $self->_writeNanosecond($val);
        $self->_writeTimeZone($val, $utc, $time_zone);
    }
}

sub writeArray {
    my $self = shift;
    my ($val, $checkRef) = @_;
    $checkRef = 1 if (!defined($checkRef));
    my $ref = $self->{'ref'};
    return $self->writeRef($ref->{$val}) if ($checkRef && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    my $count = scalar(@$val);
    $stream->write(HproseTags->TagList, 1);
    $stream->write($count, length($count)) if ($count > 0);
    $stream->write(HproseTags->TagOpenbrace, 1);
    $self->serialize($_) foreach (@$val);
    $stream->write(HproseTags->TagClosebrace, 1);    
}

sub writeHash {
    my $self = shift;
    my ($val, $checkRef) = @_;
    $checkRef = 1 if (!defined($checkRef));
    my $ref = $self->{'ref'};
    return $self->writeRef($ref->{$val}) if ($checkRef && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    my @keys = keys(%$val);
    my $count = scalar(@keys);
    $stream->write(HproseTags->TagMap, 1);
    $stream->write($count, length($count)) if ($count > 0);
    $stream->write(HproseTags->TagOpenbrace, 1);
    foreach (@keys) {
        $self->serialize($_);
        $self->serialize($val->{$_});        
    }
    $stream->write(HproseTags->TagClosebrace, 1);    
}

sub writeObject {
    my $self = shift;
    my ($val, $checkRef) = @_;
    $checkRef = 1 if (!defined($checkRef));
    my $ref = $self->{'ref'};
    return $self->writeRef($ref->{$val}) if ($checkRef && exists($ref->{$val}));
    my $stream = $self->{'stream'};
    my $classname = ref($val);
    $classname =~ s/::/_/;
    my @fields = keys(%$val);
    my $count = scalar(@fields);
    my $classref = $self->{'classref'};
    my $cr;
    if (exists($classref->{$classname})) {
        $cr = $classref->{$classname};
    }
    else {
        $cr = $self->writeClass($classname, \@fields, $count);
    }
    $ref->{$val} = scalar(keys(%$ref));
    $stream->write(HproseTags->TagObject, 1);
    $stream->write($cr, length($cr));
    $stream->write(HproseTags->TagOpenbrace, 1);
    $self->serialize($val->{$_}) foreach (@fields);
    $stream->write(HproseTags->TagClosebrace, 1);
}

sub writeClass {
    my $self = shift;
    my ($classname, $fields, $count) = @_;
    my $stream = $self->{'stream'};
    my $length = length($classname);
    $stream->write(HproseTags->TagClass, 1);
    $stream->write($length, length($length));
    $stream->write(HproseTags->TagQuote, 1);
    $stream->write($classname, $length);
    $stream->write(HproseTags->TagQuote, 1);
    $stream->write($count, length($count)) if $count > 0;
    $stream->write(HproseTags->TagOpenbrace, 1);
    $self->writeString($_) foreach (@$fields);
    $stream->write(HproseTags->TagClosebrace, 1);
    my $classref = $self->{'classref'};
    my $cr = scalar(keys(%$classref));
    $classref->{$classname} = $cr;
    return $cr;
}

sub writeRef {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    $stream->write(HproseTags->TagRef, 1);
    $stream->write($val, length($val));
    $stream->write(HproseTags->TagSemicolon, 1);
}

package HproseFormatter;




1;