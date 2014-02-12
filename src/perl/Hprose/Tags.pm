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
# Hprose/Tags.pm                                           #
#                                                          #
# Hprose Tags enum for perl                                #
#                                                          #
# LastModified: Dec 4, 2012                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################
package Hprose::Tags;

use strict;
use warnings;

use constant {
# Serialize Tags #
    Integer => 'i',
    Long => 'l',
    Double => 'd',
    Null => 'n',
    Empty => 'e',
    True => 't',
    False => 'f',
    NaN => 'N',
    Infinity => 'I',
    Date => 'D',
    Time => 'T',
    UTC => 'Z',
    Bytes => 'b',
    UTF8Char => 'u',
    String => 's',
    Guid => 'g',
    List => 'a',
    Map => 'm',
    Class => 'c',
    Object => 'o',
    Ref => 'r',
# Serialize Marks #
    Pos => '+',
    Neg => '-',
    Semicolon => ';',
    Openbrace => '{',
    Closebrace => '}',
    Quote => '"',
    Point => '.',
# Protocol Tags #
    Functions => 'F',
    Call => 'C',
    Result => 'R',
    Argument => 'A',
    Error => 'E',
    End => 'z',
};

1;