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
# LastModified: Jan 8, 2014                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::Writer;

use strict;
use warnings;
use bytes;
use Tie::RefHash;
use Hprose::Tags;
use Hprose::SimpleWriter;

our @ISA = qw(Hprose::SimpleWriter);

sub new {
    my ($class, $stream) = @_;
    tie my %ref, 'Tie::RefHash';
    my $self = $class->SUPER::new($stream);
    $self->{ref} = \%ref;
    $self->{refcount} = 0;
    bless $self, $class;
}

sub write_string {
    my ($self, $val) = @_;
    $self->{ref}->{$val} = $self->{refcount}++;
    $self->SUPER::write_string($val);
}

sub write_bytes {
    my ($self, $val) = @_;
    $self->{ref}->{$val} = $self->{refcount}++;
    $self->SUPER::write_bytes($val);
}

sub write_date {
    my ($self, $val) = @_;
    $self->{ref}->{$val} = $self->{refcount}++;
    $self->SUPER::write_date($val);
}

sub write_guid {
    my ($self, $val) = @_;
    $self->{ref}->{$val} = $self->{refcount}++;
    $self->SUPER::write_guid($val);
}

sub write_array {
    my ($self, $val) = @_;
    $self->{ref}->{$val} = $self->{refcount}++;
    $self->SUPER::write_array($val);
}

sub write_hash {
    my ($self, $val) = @_;
    $self->{ref}->{$val} = $self->{refcount}++;
    $self->SUPER::write_hash($val);
}

sub write_object {
    my ($self, $val) = @_;
    my $fields = $self->write_object_begin($val);
    $self->{ref}->{$val} = $self->{refcount}++;
    $self->write_object_end($val, $fields);
}

sub write_ref {
    my ($self, $val) = @_;
    my $ref = $self->{ref};
    if (exists($ref->{$val})) {
        $self->{stream}->print(Hprose::Tags->Ref, $ref->{$val}, Hprose::Tags->Semicolon);
        return 1;
    }
    0;
}

sub reset {
    my $self = shift;
    $self->SUPER::reset;
    undef %{$self->{ref}};
    $self->{refcount} = 0;
}

1;