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
package Hprose::Writer;

use strict;
use warnings;
use Encode;
use Error;
use Hprose::Numeric;
use Hprose::Exception;
use Hprose::Tags;

sub new {
    my $class = shift;
    my ($stream) = @_;
    use Tie::RefHash;
    tie my %ref, 'Tie::RefHash';
    my $self = bless {
        'stream' => $stream,
        'classref' => {},
        'ref' => \%ref,
    }, $class;
}

sub serialize {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    if (!defined($val)) {
        $stream->print(Hprose::Tags->Null);
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
            $stream->print(Hprose::Tags->Empty);
        }
        elsif (Encode::is_utf8($val)) {
            if (length($val) == 1) {
                Encode::_utf8_off($val);
                $stream->print(Hprose::Tags->UTF8Char, $val);
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
                    Encode::_utf8_off($val);
                    $stream->print(Hprose::Tags->UTF8Char, $val);
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
        elsif ($type eq 'IO::String') {
            $self->write_bytes(${$val->string_ref});
        }
        elsif ($type eq 'IO::Scalar') {
            $self->write_bytes(${$val->sref});
        }
        elsif ($type eq 'CODE' ||
               $type eq 'GLOB' ||
               $type eq 'LVALUE' ||
               $type eq 'FORMAT' ||
               $type eq 'Regexp' ||
               $type eq 'IO' ||
               $type =~ /^IO::.*+$/i) {
            throw Hprose::Exception('Not support to serialize this type: '. $type);
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
        return $stream->print($val);
    }
    else {
        $stream->print(Hprose::Tags->Integer, $val, Hprose::Tags->Semicolon);
    }
}

sub write_long {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    if (isnan($val)) {
        $stream->print(Hprose::Tags->NaN);
    }
    elsif (isinf($val)) {
        $stream->print(Hprose::Tags->Infinity, Hprose::Tags->Pos);
    }
    elsif (isninf($val)) {
        $stream->print(Hprose::Tags->Infinity, Hprose::Tags->Neg);
    }
    else {
        $stream->print(Hprose::Tags->Long, $val, Hprose::Tags->Semicolon);
    }
}

sub write_double {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    if (isnan($val)) {
        $stream->print(Hprose::Tags->NaN);
    }
    elsif (isinf($val)) {
        $stream->print(Hprose::Tags->Infinity, Hprose::Tags->Pos);
    }
    elsif (isninf($val)) {
        $stream->print(Hprose::Tags->Infinity, Hprose::Tags->Neg);
    }
    else {
        $stream->print(Hprose::Tags->Double, $val, Hprose::Tags->Semicolon);
    }
}

sub write_null {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->print(Hprose::Tags->Null);
}

sub write_nan {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->print(Hprose::Tags->NaN);
}

sub write_inf {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->print(Hprose::Tags->Infinity, Hprose::Tags->Pos);
}

sub write_ninf {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->print(Hprose::Tags->Infinity, Hprose::Tags->Neg);
}

sub write_boolean {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    $stream->print($val ? Hprose::Tags->True : Hprose::Tags->False);
}

sub write_empty {
    my $self = shift;
    my $stream = $self->{'stream'};
    $stream->print(Hprose::Tags->Empty);
}

sub write_string {
    my $self = shift;
    my ($val, $utf8, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    my $length = length($val);
    if ($length > 0) {
        Encode::_utf8_off($val);
        $stream->print(Hprose::Tags->String, $length, Hprose::Tags->Quote, $val, Hprose::Tags->Quote);
        Encode::_utf8_on($val) if ($utf8);
    }
    else {
        $stream->print(Hprose::Tags->String, Hprose::Tags->Quote, Hprose::Tags->Quote);
    }
}

sub write_bytes {
    my $self = shift;
    my ($val, $check_ref) = @_;
    $check_ref = 1 if (!defined($check_ref));
    my $ref = $self->{'ref'};
    return $self->write_ref($ref->{$val}) if ($check_ref && exists($ref->{$val}));
    $ref->{$val} = scalar(keys(%$ref));
    my $stream = $self->{'stream'};
    my $length = length($val);
    if ($length > 0) {
        $stream->print(Hprose::Tags->Bytes, $length, Hprose::Tags->Quote, $val, Hprose::Tags->Quote);
    }
    else {
        $stream->print(Hprose::Tags->Bytes, Hprose::Tags->Quote, Hprose::Tags->Quote);
    }
}

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
    if ($val->hour == 0 && $val->minute == 0 && $val->second == 0 && $val->nanosecond == 0) {
        $stream->print(Hprose::Tags->Date, $val->ymd(''));
    }
    else {
        if ($val->year != 1970 || $val->month != 1 || $val->day != 1) {
            $stream->print(Hprose::Tags->Date, $val->ymd(''));
        }
        $stream->print(Hprose::Tags->Time, $val->hms(''));
        if ($val->nanosecond > 0) {
            $stream->print(Hprose::Tags->Point);
            if ($val->microsecond * 1000 == $val->nanosecond) {
                if ($val->millisecond * 1000 == $val->microsecond) {
                    $stream->print($val->strftime('%3N'));
                }
                else {
                    $stream->print($val->strftime('%6N'));
                }
            }
            else {
                $stream->print($val->strftime('%9N'));
            }
        }
    }
    if ($utc) {
        $stream->print(Hprose::Tags->UTC);
        $val->set_time_zone($time_zone);
    }
    else {
        $stream->print(Hprose::Tags->Semicolon);
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
    $stream->print(Hprose::Tags->Guid, Hprose::Tags->Openbrace, $val->as_string, Hprose::Tags->Closebrace);
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
    $stream->print(Hprose::Tags->List, $count || '', Hprose::Tags->Openbrace);
    $self->serialize($_) foreach (@$val);
    $stream->print(Hprose::Tags->Closebrace);    
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
    $stream->print(Hprose::Tags->Map, $count || '', Hprose::Tags->Openbrace);
    foreach (@keys) {
        $self->serialize($_);
        $self->serialize($val->{$_});        
    }
    $stream->print(Hprose::Tags->Closebrace);    
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
    $stream->print(Hprose::Tags->Object, $cr, Hprose::Tags->Openbrace);
    $self->serialize($val->{$_}) foreach (@fields);
    $stream->print(Hprose::Tags->Closebrace);
}

sub write_class {
    my $self = shift;
    my ($classname, $fields, $count) = @_;
    my $stream = $self->{'stream'};
    my $length = length($classname);
    $stream->print(Hprose::Tags->Class, $length,
                   Hprose::Tags->Quote, $classname,
                   Hprose::Tags->Quote, $count || '',
                   Hprose::Tags->Openbrace);
    $self->write_string($_) foreach (@$fields);
    $stream->print(Hprose::Tags->Closebrace);
    my $classref = $self->{'classref'};
    my $cr = scalar(keys(%$classref));
    $classref->{$classname} = $cr;
    return $cr;
}

sub write_ref {
    my $self = shift;
    my ($val) = @_;
    my $stream = $self->{'stream'};
    $stream->print(Hprose::Tags->Ref, $val, Hprose::Tags->Semicolon);
}

1;