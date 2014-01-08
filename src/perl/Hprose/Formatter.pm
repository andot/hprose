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
# Hprose/Formatter.pm                                      #
#                                                          #
# Hprose Formatter module for perl                         #
#                                                          #
# LastModified: Jan 8, 2014                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::Formatter;

use strict;
use warnings;
use IO::String;
use Hprose::SimpleReader;
use Hprose::Reader;
use Hprose::SimpleWriter;
use Hprose::Writer;

use Exporter 'import';
our @EXPORT = qw(hprose_serialize hprose_unserialize);

sub hprose_serialize {
    my ($val, $simple) = @_;
    my $stream = IO::String->new;
    my $writer = $simple ? Hprose::SimpleWriter->new($stream) : Hprose::Writer->new($stream);
    $writer->serialize($val);
    ${$stream->string_ref};
}

sub hprose_unserialize {
    my ($data, $simple) = @_;
    my $stream = IO::String->new($data);
    my $reader = $simple ? Hprose::SimpleReader->new($stream) : Hprose::Reader->new($stream);
    $reader->unserialize;
}

sub serialize {
    my ($class, $val, $simple) = @_;
    hprose_serialize($val, $simple);
}

sub unserialize {
    my ($class, $data, $simple) = @_;
    hprose_unserialize($data, $simple);
}

1;