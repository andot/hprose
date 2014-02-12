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
# LastModified: Jan 8, 2014                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
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
    NaN => 0 + 'nan',
    Inf => 0 + 'inf',
    NInf => 0 - 'inf',
};

sub isnumeric {
    my $val = shift;
    ($val ^ $val) eq '0';
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