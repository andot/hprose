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
# LastModified: Jan 8, 2014                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################
package Hprose::Reader;

use strict;
use warnings;
use bytes;
use Hprose::IO;
use Hprose::Tags;
use Hprose::SimpleReader;

our @ISA = qw(Hprose::SimpleReader);

sub new {
    my ($class, $stream) = @_;
    my $self = $class->SUPER::new($stream);
    $self->{ref} = [];
    bless $self, $class;
}

sub read_date_without_tag {
    my $self = shift;
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $self->SUPER::read_date_without_tag;
}

sub read_time_without_tag {
    my $self = shift;
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $self->SUPER::read_time_without_tag;
}

sub read_bytes_without_tag {
    my $self = shift;
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $self->SUPER::read_bytes_without_tag;
}

sub read_string_without_tag {
    my $self = shift;
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $self->SUPER::read_string_without_tag;
}

sub read_guid_without_tag {
    my $self = shift;
    my $ref = $self->{ref};
    $ref->[scalar(@$ref)] = $self->SUPER::read_guid_without_tag;
}

sub read_array_without_tag {
    my $self = shift;
    my $ref = $self->{ref};
    my $list = $self->read_array_begin;
    $ref->[scalar(@$ref)] = $list;
    $self->read_array_end($list);
}

sub read_hash_without_tag {
    my $self = shift;
    my $ref = $self->{ref};
    my $hash = $self->read_hash_begin;
    $ref->[scalar(@$ref)] = $hash;
    $self->read_hash_end($hash);
}

sub read_object_without_tag {
    my $self = shift;
    my $ref = $self->{ref};
    my ($object, $fields, $count) = @{$self->read_object_begin};
    $ref->[scalar(@$ref)] = $object;
    $self->read_object_end($object, $fields, $count);
}

sub read_ref {
   my $self = shift;
   $self->{ref}->[readint($self->{stream}, Hprose::Tags->Semicolon)];
};

sub reset {
    my $self = shift;
    $self->SUPER::reset;
    undef @{$self->{ref}};
}

1;