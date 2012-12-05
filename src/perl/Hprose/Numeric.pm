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
# LastModified: Dec 5, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::Numeric;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw(isnumeric isint isnan isinf isninf);

use constant {
    MinInt32 => -2147483648,
    MaxInt32 => 2147483647,
    Inf => 'inf' + 0,
    NInf => -'inf',
    NaN => -'nan',
};

sub isnumeric {
    my $val = shift;
    return length( do { no warnings "numeric"; $val & "" } ) > 0;
}

sub isint {
    return (shift =~ /^-?(?:[0-9]|[1-9]\d+)$/);
}

sub isnan {
    my $val = shift;
    return ($val != $val);
}

sub isinf {
    my $val = shift;
    return ($val == Inf) || ($val =~ /^\+?(inf|infinity)$/i);
}

sub isninf {
    my $val = shift;
    return ($val == NInf) || ($val =~ /^-(inf|infinity)$/i);
}

1;