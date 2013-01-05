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
# Hprose/ClassManager.pm                                   #
#                                                          #
# Hprose ClassManager class for perl                       #
#                                                          #
# LastModified: Dec 7, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################
package Hprose::ClassManager;

use threads;
use threads::shared;

my %aliasCache: shared = ();
my %classCache: shared = ();

sub register {
    my ($self, $class, $alias) = @_;
    lock(%aliasCache);
    lock(%classCache);
    $aliasCache{$class} = $alias;
    $classCache{$alias} = $class;
}

sub get_class_alias {
    my ($self, $class) = @_;
    my $alias;
    lock(%aliasCache);
    lock(%classCache);
    if (exists($aliasCache{$class})) {
        $alias = $aliasCache{$class};
    }
    else {
        $alias = $class;
        $alias =~ s/::/_/;
        $self->register($class, $alias);
    }
    $alias;
}

sub get_class {
    my ($self, $alias) = @_;
    my $class;
    lock(%aliasCache);
    lock(%classCache);
    if (exists($classCache{$alias})) {
        $class = $classCache{$alias};
    }
    else {
        $class = $alias;
        if (!defined(&{$class.'::new'})) {
            $class =~ s/_/::/;
            if (!defined(&{$class.'::new'})) {
                do { no strict 'refs'; *{$class."::new"} = sub { bless {}, shift; }; };
            }
        }
        $self->register($class, $alias);
    }
}

1;