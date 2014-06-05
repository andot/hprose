############################################################
#                                                          #
#                          hprose                          #
#                                                          #
# Official WebSite: http://www.hprose.com/                 #
#                   http://www.hprose.org/                 #
#                                                          #
############################################################

############################################################
#                                                          #
# Hprose/ResultMode.pm                                     #
#                                                          #
# Hprose ResultMode enum for perl                          #
#                                                          #
# LastModified: Dec 4, 2012                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################
package Hprose::ResultMode;

use strict;
use warnings;

use constant {
    Normal => 0,
    Serialized => 1,
    Raw => 2,
    RawWithEndTag => 3,
};

1;