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
# LastModified: Jun 22, 2010                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

module Hprose
  autoload :Exception, 'hprose/io'
  autoload :Tags, 'hprose/io'
  autoload :ClassManager, 'hprose/io'
  autoload :Reader, 'hprose/io'
  autoload :Writer, 'hprose/io'
  autoload :Formatter, 'hprose/io'
end

Object.const_set(:HproseException, Hprose.const_get(:Exception))
Object.const_set(:HproseTags, Hprose.const_get(:Tags))
Object.const_set(:HproseClassManager, Hprose.const_get(:ClassManager))
Object.const_set(:HproseReader, Hprose.const_get(:Reader))
Object.const_set(:HproseWriter, Hprose.const_get(:Writer))
Object.const_set(:HproseFormatter, Hprose.const_get(:Formatter))