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
# hproseserver.rb                                          #
#                                                          #
# hprose server for ruby                                   #
#                                                          #
# LastModified: May 19, 2010                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

module Hprose
  autoload :Service, 'hprose/service'
  autoload :HttpService, 'hprose/httpservice'
end

Object.const_set(:HproseService, Hprose.const_get(:Service))
Object.const_set(:HproseHttpService, Hprose.const_get(:HttpService))