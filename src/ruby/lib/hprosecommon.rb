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
# hproseio.rb                                              #
#                                                          #
# hprose io for ruby                                       #
#                                                          #
# LastModified: Dec 1, 2012                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

module Hprose
  autoload :Exception, 'hprose/common'
  autoload :ResultMode, 'hprose/common'
  autoload :Filter, 'hprose/common'
end

Object.const_set(:HproseException, Hprose.const_get(:Exception))
Object.const_set(:HproseResultMode, Hprose.const_get(:ResultMode))
Object.const_set(:HproseFilter, Hprose.const_get(:Filter))