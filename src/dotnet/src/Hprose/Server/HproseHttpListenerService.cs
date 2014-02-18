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
 * HproseHttpListenerService.cs                           *
 *                                                        *
 * hprose http listener service class for C#.             *
 *                                                        *
 * LastModified: Feb 18, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
#if !(dotNET10 || dotNET11 || ClientOnly)
using System;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Security.Principal;
using Hprose.Common;

namespace Hprose.Server {

    public class HproseHttpListenerService : HproseService {

        private bool crossDomainEnabled = false;
        private bool p3pEnabled = false;
        private bool getEnabled = true;
        private bool compressionEnabled = false;
        public event SendHeaderEvent OnSendHeader = null;
        [ThreadStatic]
        private static HttpListenerContext currentContext;

        protected override object[] FixArguments(Type[] argumentTypes, object[] arguments, int count) {
            if (argumentTypes.Length != count) {
                object[] args = new object[argumentTypes.Length];
                System.Array.Copy(arguments, args, count);
                Type argType = argumentTypes[count];
                if (argType == typeof(HttpListenerContext)) {
                    args[count] = currentContext;
                }
                else if (argType == typeof(HttpListenerRequest)) {
                    args[count] = currentContext.Request;
                }
                else if (argType == typeof(HttpListenerResponse)) {
                    args[count] = currentContext.Response;
                }
                else if (argType == typeof(IPrincipal)) {
                    args[count] = currentContext.User;
                }
                return args;
            }
            return arguments;
        }

        public override HproseMethods GlobalMethods {
            get {
                if (gMethods == null) {
                    gMethods = new HproseHttpListenerMethods();
                }
                return gMethods;
            }
        }

        public static HttpListenerContext CurrentContext {
            get {
                return currentContext;
            }
        }

        public bool IsCrossDomainEnabled {
            get {
                return crossDomainEnabled;
            }
            set {
                crossDomainEnabled = value;
            }
        }

        public bool IsP3pEnabled {
            get {
                return p3pEnabled;
            }
            set {
                p3pEnabled = value;
            }
        }

        public bool IsGetEnabled {
            get {
                return getEnabled;
            }
            set {
                getEnabled = value;
            }
        }

        public bool IsCompressionEnabled {
            get {
                return compressionEnabled;
            }
            set {
                compressionEnabled = value;
            }
        }

        private Stream GetOutputStream() {
            Stream ostream = new BufferedStream(currentContext.Response.OutputStream);
            if (compressionEnabled) {
                string acceptEncoding = currentContext.Request.Headers["Accept-Encoding"];
                if (acceptEncoding != null) {
                    acceptEncoding = acceptEncoding.ToLower();
                    if (acceptEncoding.IndexOf("deflate") > -1) {
                        ostream = new DeflateStream(ostream, CompressionMode.Compress);
                    }
                    else if (acceptEncoding.IndexOf("gzip") > -1) {
                        ostream = new GZipStream(ostream, CompressionMode.Compress);
                    }
                }
            }
            return ostream;
        }

        private Stream GetInputStream() {
            Stream istream = new BufferedStream(currentContext.Request.InputStream);
            return istream;
        }

        private void SendHeader() {
            if (OnSendHeader != null) {
                OnSendHeader();
            }
            currentContext.Response.ContentType = "text/plain";
            if (p3pEnabled) {
                currentContext.Response.AddHeader("P3P", "CP=\"CAO DSP COR CUR ADM DEV TAI PSA PSD " +
                                                         "IVAi IVDi CONi TELo OTPi OUR DELi SAMi " +
                                                         "OTRi UNRi PUBi IND PHY ONL UNI PUR FIN " +
                                                         "COM NAV INT DEM CNT STA POL HEA PRE GOV\"");
            }
            if (crossDomainEnabled) {
                string origin = currentContext.Request.Headers["Origin"];
                if (origin != null && origin != "" && origin != "null") {
                    currentContext.Response.AddHeader("Access-Control-Allow-Origin", origin);
                    currentContext.Response.AddHeader("Access-Control-Allow-Credentials", "true");
                }
                else {
                    currentContext.Response.AddHeader("Access-Control-Allow-Origin", "*");
                }
            }
            if (compressionEnabled) {
                string acceptEncoding = currentContext.Request.Headers["Accept-Encoding"];
                if (acceptEncoding != null) {
                    acceptEncoding = acceptEncoding.ToLower();
                    if (acceptEncoding.IndexOf("deflate") > -1) {
                        currentContext.Response.AddHeader("Content-Encoding", "deflate");
                    }
                    else if (acceptEncoding.IndexOf("gzip") > -1) {
                        currentContext.Response.AddHeader("Content-Encoding", "gzip");
                    }
                }
            }
        }

        public void Handle(HttpListenerContext context) {
            Handle(context, null);
        }

        public void Handle(HttpListenerContext context, HproseHttpListenerMethods methods) {
            currentContext = context;
            try {
                SendHeader();
                string method = currentContext.Request.HttpMethod;
                Stream istream = null, ostream = null;
                if ((method == "GET") && getEnabled) {
                    ostream = GetOutputStream();
                    DoFunctionList(ostream, methods);
                }
                else if (method == "POST") {
                    istream = GetInputStream();
                    ostream = GetOutputStream();
                    Handle(istream, ostream, methods);
                }
                else {
                    currentContext.Response.StatusCode = 403;
                }
                currentContext.Response.Close();
            }
            finally {
                currentContext = null;
            }
        }
    }
}
#endif