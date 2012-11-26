/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/

/**********************************************************\
 *                                                        *
 * hprose.js                                              *
 *                                                        *
 * hprose for Node.js.                                    *
 *                                                        *
 * LastModified: Nov 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

module.exports = {
    common: {
        HproseException: require('./common/HproseException.js'),
        HproseResultMode: require('./common/HproseResultMode.js'),
        HproseFilter: require('./common/HproseFilter.js'),
    },
    io: {
        ClassManager: (typeof(Map) === 'undefined') ? require('./io/ClassManager.js') : require('./io/ClassManager2.js'),
        HproseBufferInputStream: require('./io/HproseBufferInputStream.js'),
        HproseBufferOutputStream: require('./io/HproseBufferOutputStream.js'),
        HproseTags: require('./io/HproseTags.js'),
        HproseReader: require('./io/HproseReader.js'),
        HproseWriter: (typeof(Map) === 'undefined') ? require('./io/HproseWriter.js') : require('./io/HproseWriter2.js'),
        HproseFormatter: require('./io/HproseFormatter.js'),
    },
    server: {
        HproseService: require('./server/HproseService.js'),
        HproseHttpService: require('./server/HproseHttpService.js'),
        HproseHttpServer: require('./server/HproseHttpServer.js'),
    },
    client: {
        HproseClient: require('./client/HproseClient.js'),
        HproseHttpClient: require('./client/HproseHttpClient.js'),
    }
}