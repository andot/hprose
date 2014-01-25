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
 * HproseHttpService.cs                                   *
 *                                                        *
 * hprose http service class for C#.                      *
 *                                                        *
 * LastModified: Nov 6, 2012                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
#if !(ClientOnly || ClientProfile)
using System;
using System.IO;
using System.IO.Compression;
using System.Web;
using System.Web.SessionState;
using Hprose.Common;

namespace Hprose.Server {

    public class HproseHttpService : HproseService {

        private bool crossDomainEnabled = false;
        private bool p3pEnabled = false;
        private bool getEnabled = true;
        private bool compressionEnabled = false;
        [ThreadStatic]
        private static HttpContext currentContext;
        [ThreadStatic]
        private static Stream ostream;
        [ThreadStatic]
        private static Stream istream;

        protected override object[] FixArguments(Type[] argumentTypes, object[] arguments, int count) {
            if (argumentTypes.Length != count) {
                object[] args = new object[argumentTypes.Length];
                System.Array.Copy(arguments, args, count);
                Type argType = argumentTypes[count];
                if (argType == typeof(HttpContext)) {
                    args[count] = currentContext;
                }
                else if (argType == typeof(HttpRequest)) {
                    args[count] = currentContext.Request;
                }
                else if (argType == typeof(HttpResponse)) {
                    args[count] = currentContext.Response;
                }
                else if (argType == typeof(HttpServerUtility)) {
                    args[count] = currentContext.Server;
                }
                else if (argType == typeof(HttpApplicationState)) {
                    args[count] = currentContext.Application;
                }
                else if (argType == typeof(HttpSessionState)) {
                    args[count] = currentContext.Session;
                }
                return args;
            }
            return arguments;
        }

        public override HproseMethods GlobalMethods {
            get {
                if (globalMethods == null) {
                    globalMethods = new HproseHttpMethods();
                }
                return globalMethods;
            }
        }

        public static HttpContext CurrentContext {
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

        protected override Stream OutputStream {
            get {
                if (ostream == null) {
                    ostream = new BufferedStream(currentContext.Response.OutputStream);
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
                }
                return ostream;
            }
        }

        protected override Stream InputStream {
            get {
                if (istream == null) {
                    istream = new BufferedStream(currentContext.Request.InputStream);
                }
                return istream;
            }
        }

        protected override void SendHeader() {
            base.SendHeader();
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

        public override void Handle() {
            Handle(HttpContext.Current, null);
        }

        public override void Handle(HproseMethods methods) {
            Handle(HttpContext.Current, (HproseHttpMethods) methods);
        }

        public void Handle(HttpContext context) {
            Handle(context, null);
        }

        public void Handle(HttpContext context, HproseHttpMethods methods) {
            currentContext = context;
            try {
                string method = currentContext.Request.HttpMethod;
                if ((method == "GET") && getEnabled) {
                    DoFunctionList(methods);
                }
                else if (method == "POST") {
                    base.Handle(methods);
                }
                else {
                    currentContext.Response.StatusCode = 405;
                }
                if (istream != null) istream.Close();
                if (ostream != null) ostream.Close();
                currentContext.Response.End();
            }
            finally {
                istream = null;
                ostream = null;
                currentContext = null;
            }
        }
    }
}
#endif