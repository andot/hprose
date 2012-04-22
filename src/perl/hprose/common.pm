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
# hprose/common.pm                                         #
#                                                          #
# hprose common for perl                                   #
#                                                          #
# LastModified: May 16, 2010                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package HproseException;

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