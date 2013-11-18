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
 * LastModified: Nov 18, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

global.HproseException = require('./common/HproseException.js');
global.HproseResultMode = require('./common/HproseResultMode.js');
global.HproseFilter = require('./common/HproseFilter.js');
global.HproseClassManager = require('./io/HproseClassManager.js'),
global.HproseBufferInputStream = require('./io/HproseBufferInputStream.js');
global.HproseBufferOutputStream = require('./io/HproseBufferOutputStream.js');
global.HproseTags = require('./io/HproseTags.js');
global.HproseRawReader = require('./io/HproseRawReader.js');
global.HproseSimpleReader = require('./io/HproseSimpleReader.js');
global.HproseSimpleWriter = require('./io/HproseSimpleWriter.js');
global.HproseReader = require('./io/HproseReader.js');
global.HproseWriter = require('./io/HproseWriter.js');
global.HproseFormatter = require('./io/HproseFormatter.js');
global.HproseService = require('./server/HproseService.js');
global.HproseHttpService = require('./server/HproseHttpService.js');
global.HproseHttpServer = require('./server/HproseHttpServer.js');
global.HproseClient = require('./client/HproseClient.js');
global.HproseHttpClient = require('./client/HproseHttpClient.js');

module.exports = {
    common: {
        Exception: global.HproseException,
        ResultMode: global.HproseResultMode,
        Filter: global.HproseFilter
    },
    io: {
        ClassManager: global.HproseClassManager,
        BufferInputStream: global.HproseBufferInputStream,
        BufferOutputStream: global.HproseBufferOutputStream,
        Tags: global.HproseTags,
        RawReader: global.HproseRawReader,
        SimpleReader: global.HproseSimpleReader,
        SimpleWriter: global.HproseSimpleWriter,
        Reader: global.HproseReader,
        Writer: global.HproseWriter,
        Formatter: global.HproseFormatter
    },
    server: {
        Service: global.HproseService,
        HttpService: global.HproseHttpService,
        HttpServer: global.HproseHttpServer
    },
    client: {
        Client: global.HproseClient,
        HttpClient: global.HproseHttpClient
    }
}