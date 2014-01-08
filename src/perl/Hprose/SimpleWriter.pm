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
# Hprose/SimpleWriter.pm                                   #
#                                                          #
# Hprose SimpleWriter class for perl                       #
#                                                          #
# LastModified: Jan 8, 2014                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::SimpleWriter;

use strict;
use warnings;
use bytes;
use Error;
use Encode;
use Tie::RefHash;
use Hprose::IO;
use Hprose::Numeric;
use Hprose::Exception;
use Hprose::Tags;
use Hprose::ClassManager;

my $write_scaler_ref = sub { shift->write_scalar(${shift()}); };
my $throw = sub { shift; throw Hprose::Exception('Not support to serialize this type: '. ref(shift)); };
my %serializeMethod = (
    'SCALAR' => $write_scaler_ref,
    'VSTRING' => $write_scaler_ref,
    'REF' => sub { shift->serialize(${shift()}); },
    'ARRAY' => \&write_array_with_ref,
    'HASH' => \&write_hash_with_ref,
    'Math::BigInt' => \&write_long,
    'Math::BigFloat' => \&write_double,
    'DateTime' => \&write_date_with_ref,
    'Data::GUID' => \& write_guid_with_ref,
    'IO::String' => sub { shift->write_bytes_with_ref(${shift->string_ref}); },
    'IO::Scalar' => sub { shift->write_bytes_with_ref(${shift->sref}); },
    'CODE' => $throw,
    'GLOB' => $throw,
    'LVALUE' => $throw,
    'FORMAT' => $throw,
    'Regexp' => $throw,
    'IO' => $throw
);
my %fieldsCache = ();

sub new {
    my ($class, $stream) = @_;
    bless {
        stream => $stream,
        classref => {},
        classrefcount => 0,
    }, $class;
}

sub serialize {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
    my $type = ref($val);
    if ($type) {
        if (exists($serializeMethod{$type})) {
            $serializeMethod{$type}($self, $val);
        }
        elsif ($type =~ /^IO::.*+$/i) {
            $self->$throw($val);
        }
        else {
            $self->write_object_with_ref($val);
        }
    }
    else {
        $self->write_scalar($val);
    }
}

sub write_scalar {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
    if (!defined($val)) {
        return $stream->print(Hprose::Tags->Null);
    }
    elsif (isnumeric($val)) {
        if (isint($val)) {
            if ($val >= Hprose::Numeric->MinInt32 && $val <= Hprose::Numeric->MaxInt32) {
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
        Encode::_utf8_off($val);
        if (length($val) < 4 && unicode_length($val) == 1) {
            $stream->print(Hprose::Tags->UTF8Char, $val);
        }
        else {
            $self->write_string_with_ref($val);
        }
        Encode::_utf8_on($val);
    }
    else {
        Encode::_utf8_on($val);
        if (Encode::is_utf8($val, 1)) {
            Encode::_utf8_off($val);
            if (length($val) < 4 && unicode_length($val) == 1) {
                $stream->print(Hprose::Tags->UTF8Char, $val);
            }
            else {
                $self->write_string_with_ref($val);
            }
        }
        else {
            Encode::_utf8_off($val);
            $self->write_bytes_with_ref($val);
        }
    }
}

sub write_integer {
    my ($self, $val) = @_;
    $val = int($val);
    my $stream = $self->{stream};
    if ($val >= 0 && $val <= 9) {
        $stream->print($val);
    }
    else {
        $stream->print(Hprose::Tags->Integer, $val, Hprose::Tags->Semicolon);
    }
}

sub write_long {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
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
    my ($self, $val) = @_;
    my $stream = $self->{stream};
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
    shift->{stream}->print(Hprose::Tags->Null);
}

sub write_nan {
    shift->{stream}->print(Hprose::Tags->NaN);
}

sub write_inf {
    shift->{stream}->print(Hprose::Tags->Infinity, Hprose::Tags->Pos);
}

sub write_ninf {
    shift->{stream}->print(Hprose::Tags->Infinity, Hprose::Tags->Neg);
}

sub write_boolean {
    shift->{stream}->print(shift() ? Hprose::Tags->True : Hprose::Tags->False);
}

sub write_empty {
    shift->{stream}->print(Hprose::Tags->Empty);
}

sub write_string {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
    my $length = unicode_length($val);
    if ($length) {
        $stream->print(Hprose::Tags->String, $length, Hprose::Tags->Quote, $val, Hprose::Tags->Quote);
    }
    else {
        $stream->print(Hprose::Tags->String, Hprose::Tags->Quote, Hprose::Tags->Quote);
    }
}

sub write_string_with_ref {
    my ($self, $val) = @_;
    $self->write_ref($val) or $self->write_string($val);
}

sub write_bytes {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
    my $length = length($val);
    if ($length) {
        $stream->print(Hprose::Tags->Bytes, $length, Hprose::Tags->Quote, $val, Hprose::Tags->Quote);
    }
    else {
        $stream->print(Hprose::Tags->Bytes, Hprose::Tags->Quote, Hprose::Tags->Quote);
    }
}

sub write_bytes_with_ref {
    my ($self, $val) = @_;
    $self->write_ref($val) or $self->write_bytes($val);
}

sub write_date {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
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

sub write_date_with_ref {
    my ($self, $val) = @_;
    $self->write_ref($val) or $self->write_date($val);
}

sub write_guid {
    my ($self, $val) = @_;
    $self->{stream}->print(Hprose::Tags->Guid, Hprose::Tags->Openbrace, $val->as_string, Hprose::Tags->Closebrace);
}

sub write_guid_with_ref {
    my ($self, $val) = @_;
    $self->write_ref($val) or $self->write_guid($val);
}

sub write_array {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
    $stream->print(Hprose::Tags->List, scalar(@$val) || '', Hprose::Tags->Openbrace);
    $self->serialize($_) foreach (@$val);
    $stream->print(Hprose::Tags->Closebrace);    
}

sub write_array_with_ref {
    my ($self, $val) = @_;
    $self->write_ref($val) or $self->write_array($val);
}

sub write_hash {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
    my @keys = keys(%$val);
    $stream->print(Hprose::Tags->Map, scalar(@keys) || '', Hprose::Tags->Openbrace);
    foreach (@keys) {
        $self->serialize($_);
        $self->serialize($val->{$_});        
    }
    $stream->print(Hprose::Tags->Closebrace);    
}

sub write_hash_with_ref {
    my ($self, $val) = @_;
    $self->write_ref($val) or $self->write_hash($val);
}

sub write_object_begin {
    my ($self, $val) = @_;
    my $stream = $self->{stream};
    my $classname = Hprose::ClassManager->get_class_alias(ref($val));
    my $fields = exists($fieldsCache{$classname}) ? $fieldsCache{$classname} : $fieldsCache{$classname} = [keys(%$val)];
    my $classref = $self->{classref};
    my $index = exists($classref->{$classname}) ? $classref->{$classname} : $self->write_class($classname, $fields);
    $stream->print(Hprose::Tags->Object, $index, Hprose::Tags->Openbrace);
    $fields;
}

sub write_object_end {
    my ($self, $val, $fields) = @_;
    $self->serialize($val->{$_}) foreach (@$fields);
    $self->{stream}->print(Hprose::Tags->Closebrace);
}

sub write_object {
    my ($self, $val) = @_;
    $self->write_object_end($val, $self->write_object_begin($val));
}

sub write_object_with_ref {
    my ($self, $val) = @_;
    $self->write_ref($val) or $self->write_object($val);
}

sub write_class {
    my ($self, $classname, $fields) = @_;
    my $stream = $self->{stream};
    my $length = unicode_length($classname);
    $stream->print(Hprose::Tags->Class, $length,
                   Hprose::Tags->Quote, $classname,
                   Hprose::Tags->Quote, scalar(@$fields) || '',
                   Hprose::Tags->Openbrace);
    $self->write_string($_) foreach (@$fields);
    $stream->print(Hprose::Tags->Closebrace);
    my $index = $self->{classrefcount}++;
    $self->{classref}->{$classname} = $index;
    return $index;
}

sub write_ref {
    0;
}

sub reset {
    my $self = shift;
    undef %{$self->{classref}};
    $self->{classrefcount} = 0;
}

1;