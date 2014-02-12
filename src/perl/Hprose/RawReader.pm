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
# Hprose/RawReader.pm                                      #
#                                                          #
# Hprose RawReader class for perl                          #
#                                                          #
# LastModified: Feb 8, 2014                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################
package Hprose::RawReader;

use strict;
use warnings;
use bytes;
use Error;
use Hprose::Exception;
use Hprose::IO;
use Hprose::Tags;

sub new {
    my ($class, $stream) = @_;
    my $self = bless {
        stream => $stream,
    }, $class;
}

sub unexpected_tag {
    my ($self, $tag, $expect_tags) = @_;
    if (!defined($tag)) {
        throw Hprose::Exception("No byte found in stream");
    }
    elsif (!defined($expect_tags)) {
        throw Hprose::Exception("'$tag' is not the expected tag");
    }
    else {
        throw Hprose::Exception("Tag '$expect_tags' expected, but '$tag' found in stream");
    }
}

my %readRawMethod;

my $read_raw = sub {
    my ($self, $sref, $tag) = @_;
    my $stream = $self->{stream};
    if (defined($tag) && exists($readRawMethod{$tag})) {
        $$sref .= $tag;
        $readRawMethod{$tag}($self, $sref);
    }
    else {
        $self->unexpected_tag($tag);
    }
};

my $read_number_raw = sub {
    my ($self, $sref) = @_;
    my $stream, $tag;
    for ($stream = $self->{stream};
         $stream->read($tag, 1, 0);
         last if ($tag eq Hprose::Tags->Semicolon)) {
        $$sref .= $tag;
    }
};

my $read_infinity_raw = sub {
    my ($self, $sref) = @_;
    $$sref .= $self->{stream}->getc;
};

my $read_datetime_raw = sub {
    my ($self, $sref) = @_;
    my $stream, $tag;
    for ($stream = $self->{stream};
         $stream->read($tag, 1, 0);
         last if ($tag eq Hprose::Tags->Semicolon ||
                  $tag eq Hprose::Tags->UTC)) {
        $$sref .= $tag;
    }
};

my $read_utf8char_raw = sub {
    my ($self, $sref) = @_;
    $$sref .= readutf8($self->{stream}, 1);
};

my $read_bytes_raw = sub {
    my ($self, $sref) = @_;
    my $stream = $self->{stream};
    my $count = readuntil($stream, Hprose::Tags->Quote);
    $$sref .= $count . Hprose::Tags->Quote;
    $count = 0 if $count eq '';
    $stream->read($$sref, $count + 1, length($$sref));
};

my $read_string_raw = sub {
    my ($self, $sref) = @_;
    my $stream = $self->{stream};
    my $count = readuntil($stream, Hprose::Tags->Quote);
    $$sref .= $count . Hprose::Tags->Quote;
    $count = 0 if $count eq '';
    $$sref .= readutf8($stream, $count + 1);
};

my $read_guid_raw = sub {
    my ($self, $sref) = @_;
    $self->{stream}->read($$sref, 38, length($$sref));
};

my $read_complex_raw = sub {
    my ($self, $sref) = @_;
    my $stream, $tag;
    for ($stream = $self->{stream};
         $stream->read($tag, 1, 0);
         last if ($tag eq Hprose::Tags->Openbrace)) {
        $$sref .= $tag;
    }
    while (($tag = $stream->getc) &&
           $tag ne Hprose::Tags->Closebrace) {
        $self->$read_raw($sref, $tag);
    }
    $$sref .= $tag if (defined($tag));
};

my $read_class_raw = sub {
    my ($self, $sref) = @_;
    $self->$read_complex_raw($sref);
    $self->$read_raw($sref, $self->{stream}->getc);
};

my $read_error_raw = sub {
    my ($self, $sref) = @_;
    $self->$read_raw($sref, $self->{stream}->getc);
};

%readRawMethod = (
    '0' => sub {},
    '1' => sub {},
    '2' => sub {},
    '3' => sub {},
    '4' => sub {},
    '5' => sub {},
    '6' => sub {},
    '7' => sub {},
    '8' => sub {},
    '9' => sub {},
    Hprose::Tags->Null => sub {},
    Hprose::Tags->Empty => sub {},
    Hprose::Tags->True => sub {},
    Hprose::Tags->False => sub {},
    Hprose::Tags->NaN => sub {},
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
    $self->$read_raw(\$str, $self->{stream}->getc);
    $str;
}

1;