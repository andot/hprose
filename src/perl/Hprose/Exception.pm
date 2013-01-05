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
# Hprose/Exception.pm                                      #
#                                                          #
# Hprose Exception for perl                                #
#                                                          #
# LastModified: Dec 4, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::Exception;

use strict;
use warnings;
use Error;
use base qw(Error);

sub new {
    my $self = shift;
    my $text = "" . shift;
    my @args = ();

    local $Error::Depth = $Error::Depth + 1;
    local $Error::Debug = 1;  # Enables storing of stacktrace

    $self->SUPER::new(-text => $text, @args);
}

1;