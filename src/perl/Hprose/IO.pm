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
# Hprose/IO.pm                                             #
#                                                          #
# Hprose IO subs for perl                                  #
#                                                          #
# LastModified: Jan 8, 2014                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################
package Hprose::IO;

use strict;
use warnings;
use bytes;

use Exporter 'import';
our @EXPORT = qw(unicode_length readuntil readint readutf8);

sub unicode_length {
    my $str = shift;
    my $pos = 0;
    my $length = length($str);
    my $len = $length;
    while ($pos < $length) {
        my $a = ord(substr($str, $pos++, 1));
        if ($a < 0x80) {
            next;
        }
        elsif (($a & 0xE0) == 0xC0) {
            ++$pos;
            --$len;
        }
        elsif (($a & 0xF0) == 0xE0) {
            $pos += 2;
            $len -= 2;
        }
        elsif (($a & 0xF8) == 0xF0) {
            $pos += 3;
            $len -= 2;
        }
    }
    return $len;
}

sub readuntil {
    my ($stream, $tag) = @_;
    my $s = '';
    my $c;
    while ($stream->read($c, 1, 0) && $c ne $tag) { $s .= $c; }
    $s;
}

sub readint {
    my ($stream, $tag) = @_;
    my $s = readuntil($stream, $tag);
    return 0 if ($s eq '');
    int($s);
}

sub readutf8 {
    my ($stream, $len) = @_;
    return '' if ($len == 0);
    my $str = '';
    my $pos = 0;
    for (my $i = 0; $i < $len; ++$i) {
        my $char;
        $stream->read($char, 1, 0);
        my $ord = ord($char);
        $str .= $char;
        ++$pos;
        if ($ord < 0x80) {
            next;
        }
        elsif (($ord & 0xE0) == 0xC0) {
            $stream->read($str, 1, $pos);
            ++$pos;
        }
        elsif (($ord & 0xF0) == 0xE0) {
            $stream->read($str, 2, $pos);
            $pos += 2;
        }
        elsif (($ord & 0xF8) == 0xF0) {
            $stream->read($str, 3, $pos);
            $pos += 3;
            ++$i;
        }
    }
    $str;
}

1;