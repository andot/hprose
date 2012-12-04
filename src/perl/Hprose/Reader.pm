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
# LastModified: Dec 4, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
use strict;
use warnings;
use Encode;
use Error qw(:try);
use Hprose::Tags;

package Hprose::Reader;

sub new {
    my $class = shift;
    my ($stream) = @_;
    my $self = bless {
        'stream' => $stream,
        'classref' => [],
        'ref' => [],
    }, $class;
}

sub unserialize {
    my $self = shift;
}

1;