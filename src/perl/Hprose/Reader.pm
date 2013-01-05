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
# Hprose/Reader.pm                                         #
#                                                          #
# Hprose Reader class for perl                             #
#                                                          #
# LastModified: Dec 13, 2012                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::Reader;

use strict;
use warnings;
use bytes;
use Encode;
use Error;
use Math::BigInt;
use Math::BigFloat;
use Tie::RefHash;
use Hprose::Exception;
use Hprose::Tags;
use Hprose::ClassManager;

my $unexpected_tag = sub {
    my ($tag, $expect_tags) = @_;
    if (!defined($tag)) {
        throw Hprose::Exception("No byte found in stream");
    }
    elsif (!defined($expect_tags)) {
        throw Hprose::Exception("'$tag' is not the expected tag");
    }
    else {
        throw Hprose::Exception("Tag '$expect_tags' expected, but '$tag' found in stream");
    }
};

my $check_tag = sub {
    my ($tag, $expect_tag) = @_;
    $unexpected_tag->($tag, $expect_tag) if ($tag != $expect_tag);
};

my $check_tags = sub {
    my ($tag, $expect_tags) = @_;
    $unexpected_tag->($tag, $expect_tags) if (index($expect_tags, $tag) < 0);
    $tag;
};

my $getc = sub {
    my $buffer = '';
    return $buffer if shift->read($buffer, 1, 0);
    undef;
};

my $readuntil = sub {
    my ($stream, $tag) = @_;
    my $s = '';
    my $c;
    while ($stream->read($c, 1, 0) && $c ne $tag) { $s .= $c; }
    $s;
};

my $readint = sub {
    my ($stream, $tag) = @_;
    my $s = $readuntil->($stream, $tag);
    return 0 if ($s eq '');
    int($s);
};

my $readutf8 = sub {
    my ($stream, $len) = @_;
    return '' if ($len == 0);
    my $str = '';
    my $pos = 0;
    for (my $i = 0; $i < $len; ++$i) {
        my $char;
        $stream->read($char, 1, 0);
        my $ord = ord($char);
        $str .= $char;
        ++$pos;
        if ($ord < 0x80) {
            next;
        }
        elsif (($ord & 0xE0) == 0xC0) {
            $stream->read($str, 1, $pos);
            ++$pos;
        }
        elsif (($ord & 0xF0) == 0xE0) {
            $stream->read($str, 2, $pos);
            $pos += 2;
        }
        elsif (($ord & 0xF8) == 0xF0) {
            $stream->read($str, 3, $pos);
            $pos += 3;
            ++$i;
        }
    }
    $str;
};

my $read_string = sub {
    my $stream = shift;
    my $len = $readint->($stream, Hprose::Tags->Quote);
    my $str = $readutf8->($stream, $len);
    $getc->($stream);
    $str;
};

my $read_nan = sub { Hprose::Numeric->NaN; };
my $read_null = sub { undef; };
my $read_empty = sub { ''; };
my $read_true = sub { 1 == 1; };
my $read_false = sub { 1 != 1; };
my $read_class = sub { my $self = shift; $self->read_class; $self->read_object; };
my $read_ref = sub { my $self = shift; $self->{ref}->[$readint->($self->{stream}, Hprose::Tags->Semicolon)]; };
my $read_error = sub { throw Hprose::Exception(shift->read_string); };

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
    Hprose::Tags->Date => \&read_date_without_tag,
    Hprose::Tags->Time => \&read_time_without_tag,
    Hprose::Tags->Bytes => \&read_bytes_without_tag,
    Hprose::Tags->UTF8Char => \&read_utf8char_without_tag,
    Hprose::Tags->String => \&read_string_without_tag,
    Hprose::Tags->Guid => \&read_guid_without_tag,
    Hprose::Tags->List => \&read_array_without_tag,
    Hprose::Tags->Map => \&read_hash_without_tag,
    Hprose::Tags->Class => $read_class,
    Hprose::Tags->Object => \&read_object_without_tag,
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Error => $read_error,
);

sub new {
    my ($class, $stream) = @_;
    my $self = bless {
        stream => $stream,
        classref => [],
        ref => [],
    }, $class;
}

sub unexpected_tag {
    my ($self, $tag, $expect_tags) = @_;
    $unexpected_tag->($tag, $expect_tags);
}

sub check_tag {
    $check_tag->($getc->(shift->{stream}), shift());
}

sub check_tags {
    $check_tags->($getc->(shift->{stream}), shift());
}

sub unserialize {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($unserializeMethod{$tag})) {
        $unserializeMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_integer_without_tag {
    $readint->(shift->{stream}, Hprose::Tags->Semicolon);
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
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readIntegerMethod{$tag})) {
        $readIntegerMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_long_without_tag {
    Math::BigInt->new($readuntil->(shift->{stream}, Hprose::Tags->Semicolon));
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
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readLongMethod{$tag})) {
        $readLongMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_double_without_tag {
    Math::BigFloat->new($readuntil->(shift->{stream}, Hprose::Tags->Semicolon));
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
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readDoubleMethod{$tag})) {
        $readDoubleMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_nan {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    ($tag eq Hprose::Tags->NaN) ? Hprose::Numeric->NaN : $unexpected_tag->($tag);
}

sub read_infinity_without_tag {
    ($getc->(shift->{stream}) eq Hprose::Tags->Neg) ?
    Hprose::Numeric->NInf :
    Hprose::Numeric->Inf;
}

sub read_infinity {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    ($tag eq Hprose::Tags->Infinity) ? $self->read_infinity_without_tag : $unexpected_tag->($tag);
}

sub read_null {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    ($tag eq Hprose::Tags->Null) ? undef : $unexpected_tag->($tag);
}

sub read_empty {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    ($tag eq Hprose::Tags->Empty) ? '' : $unexpected_tag->($tag);
}

my %readBooleanMethod = (
    Hprose::Tags->True => $read_true,
    Hprose::Tags->False => $read_false,
);

sub read_boolean {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readBooleanMethod{$tag})) {
        $readBooleanMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
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
    my $date = DateTime->new(
        year       => $year,
        month      => $month,
        day        => $day,
        hour       => $hour,
        minute     => $minute,
        second     => $second,
        nanosecond => $nanosecond,
        time_zone  => $time_zone,
    );
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $date;
}

my %readDateMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Date => \&read_date_without_tag,
);

sub read_date {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readDateMethod{$tag})) {
        $readDateMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
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
    my $time = DateTime->new(
        year       => 1970,
        month      => 1,
        day        => 1,
        hour       => $hour,
        minute     => $minute,
        second     => $second,
        nanosecond => $nanosecond,
        time_zone  => $time_zone,
    );
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $time;
}

my %readTimeMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Time => \&read_time_without_tag,
);

sub read_time {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readTimeMethod{$tag})) {
        $readTimeMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_bytes_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    my $len = $readint->($stream, Hprose::Tags->Quote);
    my $bytes;
    $stream->read($bytes, $len, 0);
    $getc->($stream);
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $bytes;
}

my %readBytesMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Bytes => \&read_bytes_without_tag,
);

sub read_bytes {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readBytesMethod{$tag})) {
        $readBytesMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_utf8char_without_tag {
    $readutf8->(shift->{stream}, 1);
}

sub read_utf8char {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    ($tag eq Hprose::Tags->UTF8Char) ? $self->read_utf8char_without_tag : $unexpected_tag->($tag);
}

sub read_string_without_tag {
    my $self = shift;
    my $str = $read_string->($self->{stream});
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $str;
}

my %readStringMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->String => \&read_string_without_tag,
);

sub read_string {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readStringMethod{$tag})) {
        $readStringMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_guid_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    $getc->($stream);
    my $guid;
    $stream->read($guid, 36, 0);
    $getc->($stream);
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $guid;
}

my %readGuidMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Guid => \&read_guid_without_tag,
);

sub read_guid {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readGuidMethod{$tag})) {
        $readGuidMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_array_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    my $ref = $self->{ref};
    my $list = [];
    $ref->[scalar(@$ref)] = $list;
    my $count = $readint->($stream, Hprose::Tags->Openbrace);
    $list->[$_] = $self->unserialize foreach (0..$count - 1);
    $getc->($stream);
    $list;
}

my %readArrayMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->List => \&read_array_without_tag,
);

sub read_array {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readArrayMethod{$tag})) {
        $readArrayMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_hash_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    my $ref = $self->{ref};
    my $hash;
    tie %$hash, 'Tie::RefHash';
    $ref->[scalar(@$ref)] = $hash;
    my $count = $readint->($stream, Hprose::Tags->Openbrace);
    $hash->{$self->unserialize} = $self->unserialize foreach (0..$count - 1);
    $getc->($stream);
    $hash;
}

my %readHashMethod = (
    Hprose::Tags->Ref => $read_ref,
    Hprose::Tags->Map => \&read_hash_without_tag,
);

sub read_hash {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readHashMethod{$tag})) {
        $readHashMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub read_class {
    my $self = shift;
    my $stream = $self->{stream};
    my $classname = $read_string->($stream);
    my $count = $readint->($stream, Hprose::Tags->Openbrace);
    my $fields = [];
    $fields->[$_] = $self->read_string foreach (0..$count - 1);
    $getc->($stream);
    my $class = Hprose::ClassManager->get_class($classname);
    my $classref = $self->{classref};
    $classref->[scalar(@$classref)] = [$class, $fields, $count];
}

sub read_object_without_tag {
    my $self = shift;
    my $stream = $self->{stream};
    my $classref = $self->{classref};
    my ($class, $fields, $count) = @{$classref->[$readint->($stream, Hprose::Tags->Openbrace)]};
    my $object = $class->new;
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $object;
    $object->{$fields->[$_]} = $self->unserialize foreach (0..$count - 1);
    $getc->($stream);
    $object;
}

my %readObjectMethod = (
    Hprose::Tags->Class => $read_class,
    Hprose::Tags->Object => \&read_object_without_tag,
    Hprose::Tags->Ref => $read_ref,
);

sub read_object {
    my $self = shift;
    my $tag = $getc->($self->{stream});
    if (defined($tag) && exists($readObjectMethod{$tag})) {
        $readObjectMethod{$tag}($self);
    }
    else {
        $unexpected_tag->($tag);
    }
}

sub reset {
    my $self = shift;
    undef @{$self->{ref}};
    undef @{$self->{classref}};
}

my %readRawMethod;

my $read_raw = sub {
    my ($self, $sref, $tag) = @_;
    my $stream = $self->{stream};
    if (defined($tag) && exists($readRawMethod{$tag})) {
        $readRawMethod{$tag}($self, $sref, $tag);
    }
    else {
        $unexpected_tag->($tag);
    }
};

my $read_tag_raw = sub {
    my ($self, $sref, $tag) = @_;
    $$sref .= $tag;
};

my $read_number_raw = sub {
    my ($self, $sref, $tag) = @_;
    my $stream = $self->{stream};
    for ($$sref .= $tag;
         $stream->read($tag, 1, 0);
         last if ($tag eq Hprose::Tags->Semicolon)) {
        $$sref .= $tag;
    }
};

my $read_infinity_raw = sub {
    my ($self, $sref, $tag) = @_;
    $$sref .= $tag . $getc->($self->{stream});
};

my $read_datetime_raw = sub {
    my ($self, $sref, $tag) = @_;
    my $stream = $self->{stream};
    for ($$sref .= $tag;
         $stream->read($tag, 1, 0);
         last if ($tag eq Hprose::Tags->Semicolon ||
                  $tag eq Hprose::Tags->UTC)) {
        $$sref .= $tag;
    }
};

my $read_utf8char_raw = sub {
    my ($self, $sref, $tag) = @_;
    $$sref .= $tag . $readutf8->($self->{stream}, 1);
};

my $read_bytes_raw = sub {
    my ($self, $sref, $tag) = @_;
    my $stream = $self->{stream};
    $$sref .= $tag;
    my $count = $readuntil->($stream, Hprose::Tags->Quote);
    $$sref .= $count . Hprose::Tags->Quote;
    $count = 0 if $count eq '';
    $stream->read($$sref, $count + 1, length($$sref));
};

my $read_string_raw = sub {
    my ($self, $sref, $tag) = @_;
    my $stream = $self->{stream};
    $$sref .= $tag;
    my $count = $readuntil->($stream, Hprose::Tags->Quote);
    $$sref .= $count . Hprose::Tags->Quote;
    $count = 0 if $count eq '';
    $$sref .= $readutf8->($stream, $count + 1);
};

my $read_guid_raw = sub {
    my ($self, $sref, $tag) = @_;
    $$sref .= $tag;
    $self->{stream}->read($$sref, 38, length($$sref));
};

my $read_complex_raw = sub {
    my ($self, $sref, $tag) = @_;
    my $stream = $self->{stream};
    for ($$sref .= $tag;
         $stream->read($tag, 1, 0);
         last if ($tag eq Hprose::Tags->Openbrace)) {
        $$sref .= $tag;
    }
    while (($tag = $getc->($stream)) &&
           $tag ne Hprose::Tags->Closebrace) {
        $self->$read_raw($sref, $tag);
    }
    $$sref .= $tag if (defined($tag));
};

my $read_class_raw = sub {
    my ($self, $sref, $tag) = @_;
    $self->$read_complex_raw($sref, $tag);
    $self->$read_raw($sref, $getc->($self->{stream}));
};

my $read_error_raw = sub {
    my ($self, $sref, $tag) = @_;
    $$sref .= $tag;
    $self->$read_raw($sref, $getc->($self->{stream}));
};

%readRawMethod = (
    '0' => $read_tag_raw,
    '1' => $read_tag_raw,
    '2' => $read_tag_raw,
    '3' => $read_tag_raw,
    '4' => $read_tag_raw,
    '5' => $read_tag_raw,
    '6' => $read_tag_raw,
    '7' => $read_tag_raw,
    '8' => $read_tag_raw,
    '9' => $read_tag_raw,
    Hprose::Tags->Null => $read_tag_raw,
    Hprose::Tags->Empty => $read_tag_raw,
    Hprose::Tags->True => $read_tag_raw,
    Hprose::Tags->False => $read_tag_raw,
    Hprose::Tags->NaN => $read_tag_raw,
    Hprose::Tags->Infinity => $read_infinity_raw,
    Hprose::Tags->Integer => $read_number_raw,
    Hprose::Tags->Long => $read_number_raw,
    Hprose::Tags->Double => $read_number_raw,
    Hprose::Tags->Ref => $read_number_raw,
    Hprose::Tags->Date => $read_datetime_raw,
    Hprose::Tags->Time => $read_datetime_raw,
    Hprose::Tags->UTF8Char => $read_utf8char_raw,
    Hprose::Tags->Bytes => $read_bytes_raw,
    Hprose::Tags->String => $read_string_raw,
    Hprose::Tags->Guid => $read_guid_raw,
    Hprose::Tags->List => $read_complex_raw,
    Hprose::Tags->Map => $read_complex_raw,
    Hprose::Tags->Object => $read_complex_raw,
    Hprose::Tags->Class => $read_class_raw,
    Hprose::Tags->Error => $read_error_raw,
);

sub read_raw {
    my $self = shift;
    my $str = '';
    $self->$read_raw(\$str, $getc->($self->{stream}));
    $str;
}

1;