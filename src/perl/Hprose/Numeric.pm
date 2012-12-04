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
# Hprose/Numeric.pm                                        #
#                                                          #
# Hprose Numeric module for perl                           #
#                                                          #
# LastModified: Dec 4, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
use strict;
use warnings;

package Hprose::Numeric;

require Exporter;
our (@ISA, @EXPORT);

BEGIN {
    @ISA = qw(Exporter);
    @EXPORT = qw(isnumeric isnan isinf isninf);
}

use constant {
    Inf => 'inf' + 0,
    NInf => -'inf',
    NaN => -'nan',
};

sub isnumeric {
    my ($val) = @_;
    return length( do { no warnings "numeric"; $val & "" } ) > 0;
}

sub isnan {
    my ($val) = @_;
    return ($val != $val);
}

sub isinf {
    my ($val) = @_;
    return ($val == Inf) || ($val =~ /^\+?(inf|infinity)$/i);
}

sub isninf {
    my ($val) = @_;
    return ($val == NInf) || ($val =~ /^-(inf|infinity)$/i);
}

1;