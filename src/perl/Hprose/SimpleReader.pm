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
# Hprose/SimpleReader.pm                                   #
#                                                          #
# Hprose SimpleReader class for perl                       #
#                                                          #
# LastModified: Jan 8, 2014                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################
package Hprose::SimpleReader;

use strict;
use warnings;
use bytes;
use Encode;
use Error;
use DateTime;
use Data::GUID;
use Math::BigInt;
use Math::BigFloat;
use Tie::RefHash;
use Hprose::Exception;
use Hprose::IO;
use Hprose::Tags;
use Hprose::ClassManager;
use Hprose::RawReader;

our @ISA = qw(Hprose::RawReader);

my $read_string = sub {
    my $stream = shift;
    my $len = readint($stream, Hprose::Tags->Quote);
    my $str = readutf8($stream, $len);
    $stream->getc;
    $str;
};

my $read_nan = sub { Hprose::Numeric->NaN; };
my $read_null = sub { undef; };
my $read_empty = sub { ''; };
my $read_true = sub { 1 == 1; };
my $read_false = sub { 1 != 1; };
my $read_class = sub { my $self = shift; $self->read_class; $self->read_object; };
my $read_error = sub { throw Hprose::Exception(shift->read_string); };
my $read_date_without_tag = sub { shift->read_date_without_tag; };
my $read_time_without_tag = sub { shift->read_time_without_tag; };
my $read_bytes_without_tag = sub { shift->read_bytes_without_tag; };
my $read_string_without_tag = sub { shift->read_string_without_tag; };
my $read_guid_without_tag = sub { shift->read_guid_without_tag; };
my $read_array_without_tag = sub { shift->read_array_without_tag; };
my $read_hash_without_tag = sub { shift->read_hash_without_tag; };
my $read_object_without_tag = sub { shift->read_object_without_tag; };
my $read_ref = sub { shift->read_ref; };



my %unserializeMethod = (
    '0' => sub { 0; },
    '1' => sub { 1; },
    '2' => sub { 2; },
    '3' => sub { 3; },
    '4' => sub { 4; },
    '5' => sub { 5; },
    '6' => sub { 6; },
    '7' => sub { 7; },
    '8' => sub { 8; },
    '9' => sub { 9; },
    Hprose::Tags->Integer => \&read_integer_without_tag,
    Hprose::Tags->Long => \&read_long_without_tag,
    Hprose::Tags->Double => \&read_double_without_tag,
    Hprose::Tags->NaN => $read_nan,
    Hprose::Tags->Infinity => \&read_infinity_without_tag,
    Hprose::Tags->Null => $read_null,
    Hprose::Tags->Empty => $read_empty,
    Hprose::Tags->True => $read_true,
    Hprose::Tags->False => $read_false,
    Hprose::Tags->Date => $read_date_without_tag,
    Hprose::Tags->Time => $read_time_without_tag,
    Hprose::Tags->Bytes => $read_bytes_without_tag,
    Hprose::Tags->UTF8Char => \&read_utf8char_without_tag,
    Hprose::Tags->String => $read_string_without_tag,
    Hprose::Tags->Guid => $read_guid_without_tag,
    Hprose::Tags->List => $read_array_without_tag,
    Hprose::Tags->Map => $read_hash_without_tag,
    Hprose::Tags->Class => $read_class,
    Hprose::Tags->Object => $read_object_without_tag,
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Error => $read_error,
);

sub new {
    my ($class, $stream) = @_;
    my $self = $class->SUPER::new($stream);
    $self->{classref} = [];
    bless $self, $class;
}

sub check_tag {
    my ($self, $expect_tag, $tag) = @_;
    $tag = $self->{stream}->getc if (!defined($tag));
    $self->unexpected_tag($tag, $expect_tag) if ($tag != $expect_tag);
}

sub check_tags {
    my ($self, $expect_tags, $tag) = @_;
    $tag = $self->{stream}->getc if (!defined($tag));
    $self->unexpected_tag($tag, $expect_tags) if (index($expect_tags, $tag) < 0);
    $tag;
}

sub unserialize {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($unserializeMethod{$tag})) ? $unserializeMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_integer_without_tag {
    readint(shift->{stream}, Hprose::Tags->Semicolon);
}

my %readIntegerMethod = (
    '0' => sub { 0; },
    '1' => sub { 1; },
    '2' => sub { 2; },
    '3' => sub { 3; },
    '4' => sub { 4; },
    '5' => sub { 5; },
    '6' => sub { 6; },
    '7' => sub { 7; },
    '8' => sub { 8; },
    '9' => sub { 9; },
    Hprose::Tags->Integer => \&read_integer_without_tag,
);

sub read_integer {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readIntegerMethod{$tag})) ? $readIntegerMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_long_without_tag {
    Math::BigInt->new(readuntil(shift->{stream}, Hprose::Tags->Semicolon));
}

my %readLongMethod = (
    '0' => sub { Math::BigInt->new(0); },
    '1' => sub { Math::BigInt->new(1); },
    '2' => sub { Math::BigInt->new(2); },
    '3' => sub { Math::BigInt->new(3); },
    '4' => sub { Math::BigInt->new(4); },
    '5' => sub { Math::BigInt->new(5); },
    '6' => sub { Math::BigInt->new(6); },
    '7' => sub { Math::BigInt->new(7); },
    '8' => sub { Math::BigInt->new(8); },
    '9' => sub { Math::BigInt->new(9); },
    Hprose::Tags->Integer => \&read_long_without_tag,
    Hprose::Tags->Long => \&read_long_without_tag,
);

sub read_long {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readLongMethod{$tag})) ? $readLongMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_double_without_tag {
    Math::BigFloat->new(readuntil(shift->{stream}, Hprose::Tags->Semicolon));
}

my %readDoubleMethod = (
    '0' => sub { Math::BigFloat->new(0); },
    '1' => sub { Math::BigFloat->new(1); },
    '2' => sub { Math::BigFloat->new(2); },
    '3' => sub { Math::BigFloat->new(3); },
    '4' => sub { Math::BigFloat->new(4); },
    '5' => sub { Math::BigFloat->new(5); },
    '6' => sub { Math::BigFloat->new(6); },
    '7' => sub { Math::BigFloat->new(7); },
    '8' => sub { Math::BigFloat->new(8); },
    '9' => sub { Math::BigFloat->new(9); },
    Hprose::Tags->Integer => \&read_double_without_tag,
    Hprose::Tags->Long => \&read_double_without_tag,
    Hprose::Tags->Double => \&read_double_without_tag,
    Hprose::Tags->NaN => $read_nan,
    Hprose::Tags->Infinity => \&read_infinity_without_tag,
);

sub read_double {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readDoubleMethod{$tag})) ? $readDoubleMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_nan {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    ($tag eq Hprose::Tags->NaN) ? Hprose::Numeric->NaN : $self->unexpected_tag($tag);
}

sub read_infinity_without_tag {
    my $tag = shift->{stream}->getc;
    ($tag eq Hprose::Tags->Neg) ? Hprose::Numeric->NInf : Hprose::Numeric->Inf;
}

sub read_infinity {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    ($tag eq Hprose::Tags->Infinity) ? $self->read_infinity_without_tag : $self->unexpected_tag($tag);
}

sub read_null {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    ($tag eq Hprose::Tags->Null) ? undef : $self->unexpected_tag($tag);
}

sub read_empty {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    ($tag eq Hprose::Tags->Empty) ? '' : $self->unexpected_tag($tag);
}

my %readBooleanMethod = (
    Hprose::Tags->True => $read_true,
    Hprose::Tags->False => $read_false,
);

sub read_boolean {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readBooleanMethod{$tag})) ? $readBooleanMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_date_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    my ($year, $month, $day, $hour, $minute, $second, $nanosecond) = (1970, 1, 1, 0, 0, 0, 0);
    $stream->read($year, 4, 0);
    $stream->read($month, 2, 0);
    $stream->read($day, 2, 0);
    my $tag;
    if ($stream->read($tag, 1, 0) && $tag eq Hprose::Tags->Time) {
        $stream->read($hour, 2, 0);
        $stream->read($minute, 2, 0);
        $stream->read($second, 2, 0);
        if ($stream->read($tag, 1, 0) && $tag eq Hprose::Tags->Point) {
            $stream->read($nanosecond, 3, 0);
            if ($stream->read($tag, 1, 0) && ($tag ge '0') && ($tag le '9')) {
                $nanosecond .= $tag;
                $stream->read($nanosecond, 2, 4);
                if ($stream->read($tag, 1, 0) && ($tag ge '0') && ($tag le '9')) {
                    $nanosecond .= $tag;
                    $stream->read($nanosecond, 2, 7);
                    $stream->read($tag, 1, 0);
                }
                else {
                    $nanosecond *= 1000;
                }
            }
            else {
                $nanosecond *= 1000000;
            }
        }
    }
    my $time_zone = ($tag eq Hprose::Tags->UTC) ? 'UTC' : 'floating';
    DateTime->new(
        year       => $year,
        month      => $month,
        day        => $day,
        hour       => $hour,
        minute     => $minute,
        second     => $second,
        nanosecond => $nanosecond,
        time_zone  => $time_zone,
    );
}

my %readDateMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Date => $read_date_without_tag,
);

sub read_date {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readDateMethod{$tag})) ? $readDateMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_time_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    my ($hour, $minute, $second, $nanosecond) = (0, 0, 0, 0);
    $stream->read($hour, 2, 0);
    $stream->read($minute, 2, 0);
    $stream->read($second, 2, 0);
    my $tag;
    if ($stream->read($tag, 1, 0) && $tag eq Hprose::Tags->Point) {
        $stream->read($nanosecond, 3, 0);
        if ($stream->read($tag, 1, 0) && ($tag ge '0') && ($tag le '9')) {
            $nanosecond .= $tag;
            $stream->read($nanosecond, 2, 4);
            if ($stream->read($tag, 1, 0) && ($tag ge '0') && ($tag le '9')) {
                $nanosecond .= $tag;
                $stream->read($nanosecond, 2, 7);
                $stream->read($tag, 1, 0);
            }
            else {
                $nanosecond *= 1000;
            }
        }
        else {
            $nanosecond *= 1000000;
        }
    }
    my $time_zone = ($tag eq Hprose::Tags->UTC) ? 'UTC' : 'floating';
    DateTime->new(
        year       => 1970,
        month      => 1,
        day        => 1,
        hour       => $hour,
        minute     => $minute,
        second     => $second,
        nanosecond => $nanosecond,
        time_zone  => $time_zone,
    );
}

my %readTimeMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Time => $read_time_without_tag,
);

sub read_time {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readTimeMethod{$tag})) ? $readTimeMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_bytes_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    my $len = readint($stream, Hprose::Tags->Quote);
    my $bytes;
    $stream->read($bytes, $len, 0);
    $stream->getc;
    $bytes;
}

my %readBytesMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Bytes => $read_bytes_without_tag,
);

sub read_bytes {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readBytesMethod{$tag})) ? $readBytesMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_utf8char_without_tag {
    readutf8(shift->{stream}, 1);
}

sub read_utf8char {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    ($tag eq Hprose::Tags->UTF8Char) ? $self->read_utf8char_without_tag : $self->unexpected_tag($tag);
}

sub read_string_without_tag {
    my $self = shift;
    $read_string->($self->{stream});
}

my %readStringMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->String => $read_string_without_tag,
);

sub read_string {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readStringMethod{$tag})) ? $readStringMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_guid_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    $stream->getc;
    my $guid;
    $stream->read($guid, 36, 0);
    $stream->getc;
    Data::GUID->from_string($guid);
}

my %readGuidMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Guid => $read_guid_without_tag,
);

sub read_guid {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readGuidMethod{$tag})) ? $readGuidMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_array_begin {
    [];
}

sub read_array_end {
    my ($self, $list) = @_;
    my $stream = $self->{stream};
    my $count = readint($stream, Hprose::Tags->Openbrace);
    $list->[$_] = $self->unserialize foreach (0..$count - 1);
    $stream->getc;
    $list;
}

sub read_array_without_tag {
    my $self = shift;
    $self->read_array_end($self->read_array_begin);
}

my %readArrayMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->List => $read_array_without_tag,
);

sub read_array {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readArrayMethod{$tag})) ? $readArrayMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_hash_begin {
    my $hash;
    tie %$hash, 'Tie::RefHash';
    $hash;
}

sub read_hash_end {
    my ($self, $hash) = @_;
    my $stream = $self->{stream};
    my $count = readint($stream, Hprose::Tags->Openbrace);
    foreach (0..$count - 1) {
        my $key = $self->unserialize;
        $hash->{$key} = $self->unserialize;
    };
    $stream->getc;
    $hash;
}

sub read_hash_without_tag {
    my $self = shift;
    $self->read_hash_end($self->read_hash_begin);
}

my %readHashMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Map => $read_hash_without_tag,
);

sub read_hash {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readHashMethod{$tag})) ? $readHashMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_class {
    my $self = shift;
    my $stream = $self->{stream};
    my $classname = $read_string->($stream);
    my $count = readint($stream, Hprose::Tags->Openbrace);
    my $fields = [];
    $fields->[$_] = $self->read_string foreach (0..$count - 1);
    $stream->getc;
    my $class = Hprose::ClassManager->get_class($classname);
    my $classref = $self->{classref};
    $classref->[scalar(@$classref)] = [$class, $fields, $count];
}

sub read_object_begin {
    my $self = shift;
    my $stream = $self->{stream};
    my $classref = $self->{classref};
    my ($class, $fields, $count) = @{$classref->[readint($stream, Hprose::Tags->Openbrace)]};
    my $object = $class->new;
    [$object, $fields, $count];
}

sub read_object_end {
    my ($self, $object, $fields, $count) = @_;
    $object->{$fields->[$_]} = $self->unserialize foreach (0..$count - 1);
    $self->{stream}->getc;
    $object;
}

sub read_object_without_tag {
    my $self = shift;
    my ($object, $fields, $count) = @{$self->read_object_begin};
    $self->read_object_end($object, $fields, $count);
}

my %readObjectMethod = (
    Hprose::Tags->Class => $read_class,
    Hprose::Tags->Object => $read_object_without_tag,
    Hprose::Tags->Ref => $read_ref,
);

sub read_object {
    my $self = shift;
    my $tag = $self->{stream}->getc;
    (defined($tag) && exists($readObjectMethod{$tag})) ? $readObjectMethod{$tag}($self) : $self->unexpected_tag($tag);
}

sub read_ref {
   my $self = shift;
   $self->unexpected_tag(Hprose::Tags->Ref);
};

sub reset {
    my $self = shift;
    undef @{$self->{classref}};
}

1;