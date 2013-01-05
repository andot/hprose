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
# hprose/common.py                                         #
#                                                          #
# hprose common for python 3.0+                            #
#                                                          #
# LastModified: Dec 1, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

class HproseResultMode:
    Normal = 0
    Serialized = 1
    Raw = 2
    RawWithEndTag = 3

class HproseException(Exception):
    pass

class HproseFilter(object):
    def inputFilter(self, instream):
        return instream;
    def outputFilter(self, outstream):
        return outstream;