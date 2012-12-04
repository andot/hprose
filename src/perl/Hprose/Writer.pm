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
# Hprose/Writer.pm                                         #
#                                                          #
# Hprose Writer class for perl                             #
#                                                          #
# LastModified: Dec 4, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
use strict;
use warnings;
use Encode;
use Error;

package Hprose::Writer;

use Hprose::Numeric;
use Hprose::Exception;
use Hprose::Tags;

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
        $stream->write(Hprose::Tags->Null, 1);
    }
    elsif (!ref($val)) {
        if (isnumeric($val)) {
            if ($val =~ /^-?(?:[0-9]|[1-9]\d+)$/) {
                if (($val >= -2147483648) && ($val <= 2147483647)) {
                    $self->write_integer($val);
                }
                else {
                    $self->write_long($val);
                }
            }
            else {
                $self->write_double($val);
            }
        }
        elsif ($val eq '') {
            $stream->write(Hprose::Tags->Empty, 1);
        }
        elsif (Encode::is_utf8($val)) {
            if (length($val) == 1) {
                $stream->write(Hprose::Tags->UTF8Char, 1);
                Encode::_utf8_off($val);
                $stream->write($val, length($val));
                Encode::_utf8_on($val);
            }
            else {
                $self->write_string($val, 1);
            }
        }
        else {
            Encode::_utf8_on($val);
            if (Encode::is_utf8($val, 1)) {
                if (length($val) == 1) {
                    $stream->write(Hprose::Tags->UTF8Char, 1);
                    Encode::_utf8_off($val);
                    $stream->write($val, length($val));
                }
                else {
                    $self->write_string($val);
                }
            }
            else {
                Encode::_utf8_off($val);
                $self->write_bytes($val);
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
            $self->write_array($val);
        }
        elsif ($type eq 'HASH') {
            $self->write_hash($val);
        }
        elsif ($type eq 'CODE' ||
               $type eq 'GLOB' ||
               $type eq 'LVALUE' ||
               $type eq 'FORMAT' ||
               $type eq 'IO' ||
               $type eq 'IO::Handle' ||
               $type eq 'Regexp') {
            throw Hprose::Exception('Not support to serialize this type: '. $type);
        }
        elsif ($type eq 'Math::BigInt') {
            $self->write_long($val);
        }
        elsif ($type eq 'Math::BigFloat') {
            $self->write_double($val);
        }
        elsif ($type eq 'DateTime') {
            $self->write_date($val);
        }
        elsif ($type eq 'Data::GUID') {
            $self->write_guid($val);
        }
        else {
            $self->write_object($val);
        }
    }
}

sub write_integer {
    my $self = shift;
    my ($val) = @_;
    $val = int($val);
    my $stream = $self->{'stream'};
    if ($val >= 0 && $val <= 9) {
        return $stream->write($val, 1);
    }
    else {
        $stream->write(Hprose::Tags->Integer, 1);
        $stream->write($val, length($val));
        $stream->write(Hprose::Tags->Semicolon, 1);
    }
}

sub write_long {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    if (isnan($val)) {
        $stream->write(Hprose::Tags->NaN, 1);
    }
    elsif (isinf($val)) {
        $stream->write(Hprose::Tags->Infinity, 1);
        $stream->write(Hprose::Tags->Pos, 1);
    }
    elsif (isninf($val)) {
        $stream->write(Hprose::Tags->Infinity, 1);
        $stream->write(Hprose::Tags->Neg, 1);
    }
    else {
        $stream->write(Hprose::Tags->Long, 1);
        $stream->write($val, length($val));
        $stream->write(Hprose::Tags->Semicolon, 1);
    }
}

sub write_double {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    if (isnan($val)) {
        $stream->write(Hprose::Tags->NaN, 1);
    }
    elsif (isinf($val)) {
        $stream->write(Hprose::Tags->Infinity, 1);
        $stream->write(Hprose::Tags->Pos, 1);
    }
    elsif (isninf($val)) {
        $stream->write(Hprose::Tags->Infinity, 1);
        $stream->write(Hprose::Tags->Neg, 1);
    }
    else {
        $stream->write(Hprose::Tags->Double, 1);
        $stream->write($val, length($val));
        $stream->write(Hprose::Tags->Semicolon, 1);
    }
}

sub write_null {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->Null, 1);
}

sub write_nan {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->NaN, 1);
}

sub write_inf {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->Infinity, 1);
    $stream->write(Hprose::Tags->Pos, 1);
}

sub write_ninf {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->Infinity, 1);
    $stream->write(Hprose::Tags->Neg, 1);
}

sub write_boolean {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    $stream->write($val ? Hprose::Tags->True : Hprose::Tags->False, 1);
}

sub write_empty {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->Empty, 1);
}

sub write_string {
    my $self = shift;
    my ($val, $utf8, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->String, 1);
    my $length = length($val);
    $stream->write($length, length($length)) if ($length > 0);
    $stream->write(Hprose::Tags->Quote, 1);
    Encode::_utf8_off($val);
    $stream->write($val, length($val));
    Encode::_utf8_on($val) if ($utf8);
    $stream->write(Hprose::Tags->Quote, 1);
}

sub write_bytes {
    my $self = shift;
    my ($val, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->Bytes, 1);
    my $length = length($val);
    $stream->write($length, length($length)) if ($length > 0);
    $stream->write(Hprose::Tags->Quote, 1);
    $stream->write($val, length($val));
    $stream->write(Hprose::Tags->Quote, 1);
}

my $write_nanosecond = sub {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    if ($val->nanosecond > 0) {
        $stream->write(Hprose::Tags->Point, 1);
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
};

my $write_time_zone = sub {
    my $self = shift;
    my ($val, $utc, $time_zone) = @_;
    my $stream = $self->{'stream'};
    if ($utc) {
        $stream->write(Hprose::Tags->UTC, 1);
        $val->set_time_zone($time_zone);
    }
    else {
        $stream->write(Hprose::Tags->Semicolon, 1);
    }
};

sub write_date {
    my $self = shift;
    my ($val, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    my $time_zone = $val->time_zone;
    my $utc = ref($time_zone) ne 'DateTime::TimeZone::Floating';
    $val->set_time_zone('UTC') if ($utc);
    if ($val->hour == 0 &&
        $val->minute == 0 &&
        $val->second == 0 &&
        $val->nanosecond == 0) {
        $stream->write(Hprose::Tags->Date, 1);
        $stream->write($val->ymd(''), 8);
        $self->$write_time_zone($val, $utc, $time_zone);
    }
    elsif ($val->year == 1970 &&
           $val->month == 1 &&
           $val->day == 1) {
        $stream->write(Hprose::Tags->Time, 1);
        $stream->write($val->hms(''), 6);
        $self->$write_nanosecond($val);
        $self->$write_time_zone($val, $utc, $time_zone);
    }
    else {
        $stream->write(Hprose::Tags->Date, 1);
        $stream->write($val->ymd(''), 8);
        $stream->write(Hprose::Tags->Time, 1);
        $stream->write($val->hms(''), 6);
        $self->$write_nanosecond($val);
        $self->$write_time_zone($val, $utc, $time_zone);
    }
}

sub write_guid {
    my $self = shift;
    my ($val, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->Guid, 1);
    $stream->write(Hprose::Tags->Openbrace, 1);
    $stream->write($val->as_string, 36);
    $stream->write(Hprose::Tags->Closebrace, 1);
}

sub write_array {
    my $self = shift;
    my ($val, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    my $count = scalar(@$val);
    $stream->write(Hprose::Tags->List, 1);
    $stream->write($count, length($count)) if ($count > 0);
    $stream->write(Hprose::Tags->Openbrace, 1);
    $self->serialize($_) foreach (@$val);
    $stream->write(Hprose::Tags->Closebrace, 1);    
}

sub write_hash {
    my $self = shift;
    my ($val, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    my @keys = keys(%$val);
    my $count = scalar(@keys);
    $stream->write(Hprose::Tags->Map, 1);
    $stream->write($count, length($count)) if ($count > 0);
    $stream->write(Hprose::Tags->Openbrace, 1);
    foreach (@keys) {
        $self->serialize($_);
        $self->serialize($val->{$_});        
    }
    $stream->write(Hprose::Tags->Closebrace, 1);    
}

sub write_object {
    my $self = shift;
    my ($val, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
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
        $cr = $self->write_class($classname, \@fields, $count);
    }
    $ref->{$val} = scalar(keys(%$ref));
    $stream->write(Hprose::Tags->Object, 1);
    $stream->write($cr, length($cr));
    $stream->write(Hprose::Tags->Openbrace, 1);
    $self->serialize($val->{$_}) foreach (@fields);
    $stream->write(Hprose::Tags->Closebrace, 1);
}

sub write_class {
    my $self = shift;
    my ($classname, $fields, $count) = @_;
    my $stream = $self->{'stream'};
    my $length = length($classname);
    $stream->write(Hprose::Tags->Class, 1);
    $stream->write($length, length($length));
    $stream->write(Hprose::Tags->Quote, 1);
    $stream->write($classname, $length);
    $stream->write(Hprose::Tags->Quote, 1);
    $stream->write($count, length($count)) if $count > 0;
    $stream->write(Hprose::Tags->Openbrace, 1);
    $self->write_string($_) foreach (@$fields);
    $stream->write(Hprose::Tags->Closebrace, 1);
    my $classref = $self->{'classref'};
    my $cr = scalar(keys(%$classref));
    $classref->{$classname} = $cr;
    return $cr;
}

sub write_ref {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    $stream->write(Hprose::Tags->Ref, 1);
    $stream->write($val, length($val));
    $stream->write(Hprose::Tags->Semicolon, 1);
}

1;