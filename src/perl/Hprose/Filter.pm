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
# Hprose/Filter.pm                                         #
#                                                          #
# Hprose Filter class for perl                             #
#                                                          #
# LastModified: Dec 5, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::Filter;

use strict;
use warnings;

sub new {
    bless {}, shift;
}

sub input_filter { $_[1] }

sub output_filter { $_[1] }

1;