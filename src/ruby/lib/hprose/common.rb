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
# hprose/common.rb                                         #
#                                                          #
# hprose common library for ruby                           #
#                                                          #
# LastModified: Dec 2, 2012                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

module Hprose
  class Exception < Exception; end

  module ResultMode
    Normal = 0
    Serialized = 1
    Raw = 2
    RawWithEndTag = 3
  end

  class Filter
    def input_filter(data)
      return data
    end
    def output_filter(data)
      return data
    end
  end

end # module Hprose