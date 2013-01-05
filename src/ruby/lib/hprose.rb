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
# hprose.rb                                                #
#                                                          #
# hprose for ruby                                          #
#                                                          #
# LastModified: Dec 1, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

module Hprose
  autoload :Exception, 'hprose/common'
  autoload :ResultMode, 'hprose/common'
  autoload :Filter, 'hprose/common'
  autoload :Tags, 'hprose/io'
  autoload :ClassManager, 'hprose/io'
  autoload :Reader, 'hprose/io'
  autoload :Writer, 'hprose/io'
  autoload :Formatter, 'hprose/io'
  autoload :Client, 'hprose/client'
  autoload :HttpClient, 'hprose/httpclient'
  autoload :Service, 'hprose/service'
  autoload :HttpService, 'hprose/httpservice'
end

Object.const_set(:HproseException, Hprose.const_get(:Exception))
Object.const_set(:HproseResultMode, Hprose.const_get(:ResultMode))
Object.const_set(:HproseFilter, Hprose.const_get(:Filter))
Object.const_set(:HproseTags, Hprose.const_get(:Tags))
Object.const_set(:HproseClassManager, Hprose.const_get(:ClassManager))
Object.const_set(:HproseReader, Hprose.const_get(:Reader))
Object.const_set(:HproseWriter, Hprose.const_get(:Writer))
Object.const_set(:HproseFormatter, Hprose.const_get(:Formatter))
Object.const_set(:HproseClient, Hprose.const_get(:Client))
Object.const_set(:HproseHttpClient, Hprose.const_get(:HttpClient))
Object.const_set(:HproseService, Hprose.const_get(:Service))
Object.const_set(:HproseHttpService, Hprose.const_get(:HttpService))