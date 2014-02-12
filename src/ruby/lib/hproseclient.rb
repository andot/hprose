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
# hproseclient.rb                                          #
#                                                          #
# hprose client for ruby                                   #
#                                                          #
# LastModified: May 19, 2010                               #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

module Hprose
  autoload :Client, 'hprose/client'
  autoload :HttpClient, 'hprose/httpclient'
end

Object.const_set(:HproseClient, Hprose.const_get(:Client))
Object.const_set(:HproseHttpClient, Hprose.const_get(:HttpClient))