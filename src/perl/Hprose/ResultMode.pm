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
# Hprose/ResultMode.pm                                     #
#                                                          #
# Hprose ResultMode enum for perl                          #
#                                                          #
# LastModified: Dec 3, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
use strict;
use warnings;

package Hprose::ResultMode;

use constant {
    Normal => 0,
    Serialized => 1,
    Raw => 2,
    RawWithEndTag => 3,
};

1;