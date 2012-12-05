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
# LastModified: Dec 5, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::Reader;

use strict;
use warnings;
use Encode;
use Error qw(:try);
use Hprose::Tags;

sub new {
    my ($class, $stream) = @_;
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