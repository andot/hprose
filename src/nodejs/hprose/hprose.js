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
 * LastModified: Nov 7, 2013                              *
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
        ClassManager: require('./io/ClassManager.js'),
        HproseBufferInputStream: require('./io/HproseBufferInputStream.js'),
        HproseBufferOutputStream: require('./io/HproseBufferOutputStream.js'),
        HproseTags: require('./io/HproseTags.js'),
        HproseRawReader: require('./io/HproseRawReader.js'),
        HproseSimpleReader: require('./io/HproseSimpleReader.js'),
        HproseSimpleWriter: require('./io/HproseSimpleWriter.js'),
        HproseReader: require('./io/HproseReader.js'),
        HproseWriter: require('./io/HproseWriter.js'),
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