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
 * HproseHttpListenerServer.cs                            *
 *                                                        *
 * hprose http listener server class for C#.              *
 *                                                        *
 * LastModified: Feb 18, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
#if !(dotNET10 || dotNET11 || ClientOnly)
using System;
using System.IO;
using System.Net;
using System.Text;
using Hprose.IO;
using Hprose.Common;

namespace Hprose.Server {
    public class HproseHttpListenerServer {
        private HproseHttpListenerService service = new HproseHttpListenerService();
        private HttpListener Listener = new HttpListener();
        private string url = null;
        private string crossDomainXmlFile = null;
        private string crossDomainXmlContent = null;
        private string clientAccessPolicyXmlFile = null;
        private string clientAccessPolicyXmlContent = null;
        private string lastModified = null;
        private string etag = null;
        private int tCount = 2;
        public event BeforeInvokeEvent OnBeforeInvoke = null;
        public event AfterInvokeEvent OnAfterInvoke = null;
        public event SendHeaderEvent OnSendHeader = null;
        public event SendErrorEvent OnSendError = null;

        public HproseHttpListenerServer(string url) {
            Url = url;
        }

        public HproseHttpListenerServer()
            : this("http://127.0.0.1/") {
        }

        public string Url {
            get {
                return url;
            }
            set {
                url = value;
                Listener.Prefixes.Clear();
                Listener.Prefixes.Add(url);
            }
        }

        public HproseMethods Methods {
            get {
                return service.GlobalMethods;
            }
        }

        public int ThreadCount {
            get {
                return tCount;
            }
            set {
                tCount = value;
            }
        }

        public bool IsDebugEnabled {
            get {
                return service.IsDebugEnabled;
            }
            set {
                service.IsDebugEnabled = value;
            }
        }

        public bool IsCrossDomainEnabled {
            get {
                return service.IsCrossDomainEnabled;
            }
            set {
                service.IsCrossDomainEnabled = value;
            }
        }

        public bool IsP3pEnabled {
            get {
                return service.IsP3pEnabled;
            }
            set {
                service.IsP3pEnabled = value;
            }
        }

        public bool IsGetEnabled {
            get {
                return service.IsGetEnabled;
            }
            set {
                service.IsGetEnabled = value;
            }
        }

        public bool IsCompressionEnabled {
            get {
                return service.IsCompressionEnabled;
            }
            set {
                service.IsCompressionEnabled = value;
            }
        }

        public HproseMode Mode {
            get {
                return service.Mode;
            }
            set {
                service.Mode = value;
            }
        }

        public IHproseFilter Filter {
            get {
                return service.Filter;
            }
            set {
                service.Filter = value;
            }
        }

        public bool IsStarted {
            get {
                return Listener.IsListening;
            }
        }

        public string CrossDomainXmlFile {
            get {
                return crossDomainXmlFile;
            }
            set {
                crossDomainXmlFile = value;
                crossDomainXmlContent = File.ReadAllText(value);
            }
        }

        public string CrossDomainXmlContent {
            get {
                return crossDomainXmlContent;
            }
            set {
                crossDomainXmlContent = value;
                crossDomainXmlFile = null;
            }
        }

        public string ClientAccessPolicyXmlFile {
            get {
                return clientAccessPolicyXmlFile;
            }
            set {
                clientAccessPolicyXmlFile = value;
                clientAccessPolicyXmlContent = File.ReadAllText(value);
            }
        }

        public string ClientAccessPolicyXmlContent {
            get {
                return clientAccessPolicyXmlContent;
            }
            set {
                clientAccessPolicyXmlContent = value;
                clientAccessPolicyXmlFile = null;
            }
        }

        private bool CrossDomainXmlHandler(HttpListenerContext context) {
            HttpListenerRequest request = context.Request;
            HttpListenerResponse response = context.Response;
            if (request.Url.AbsolutePath.ToLower() == "/crossdomain.xml") {
                if (request.Headers["If-Modified-Since"] == lastModified &&
                    request.Headers["If-None-Match"] == etag) {
                    response.StatusCode = 304;
                }
                else {
                    byte[] crossDomainXml = Encoding.ASCII.GetBytes(crossDomainXmlContent);
                    response.AppendHeader("Last-Modified", lastModified);
                    response.AppendHeader("Etag", etag);
                    response.ContentType = "text/xml";
                    response.ContentLength64 = crossDomainXml.Length;
                    response.SendChunked = false;
                    response.OutputStream.Write(crossDomainXml, 0, crossDomainXml.Length);
                    response.OutputStream.Flush();
                }
                response.Close();
                return true;
            }
            return false;
        }

        private bool ClientAccessPolicyXmlHandler(HttpListenerContext context) {
            HttpListenerRequest request = context.Request;
            HttpListenerResponse response = context.Response;
            if (request.Url.AbsolutePath.ToLower() == "/clientaccesspolicy.xml") {
                if (request.Headers["If-Modified-Since"] == lastModified &&
                    request.Headers["If-None-Match"] == etag) {
                    response.StatusCode = 304;
                }
                else {
                    byte[] clientAccessPolicyXml = Encoding.ASCII.GetBytes(clientAccessPolicyXmlContent);
                    response.AppendHeader("Last-Modified", lastModified);
                    response.AppendHeader("Etag", etag);
                    response.ContentType = "text/xml";
                    response.ContentLength64 = clientAccessPolicyXml.Length;
                    response.SendChunked = false;
                    response.OutputStream.Write(clientAccessPolicyXml, 0, clientAccessPolicyXml.Length);
                    response.OutputStream.Flush();
                }
                response.Close();
                return true;
            }
            return false;
        }

        public void Start() {
            if (Listener.IsListening)
                return;
            service.OnBeforeInvoke += OnBeforeInvoke;
            service.OnAfterInvoke += OnAfterInvoke;
            service.OnSendHeader += OnSendHeader;
            service.OnSendError += OnSendError;
            lastModified = DateTime.Now.ToString("R");
            etag = '"' + new Random().Next().ToString("x") + ":" + new Random().Next().ToString() + '"';
            Listener.Start();
            for (int i = 0; i < tCount; i++) {
                Listener.BeginGetContext(GetContext, Listener);
            }
        }

        public void Stop() {
            Listener.Stop();
        }

        public void Close() {
            Listener.Close();
            Listener = new HttpListener();
            Listener.Prefixes.Add(url);
        }

        public void Abort() {
            Listener.Abort();
            Listener = new HttpListener();
            Listener.Prefixes.Add(url);
        }

        private void GetContext(IAsyncResult result) {
            try {
                HttpListenerContext context = Listener.EndGetContext(result);
                Listener.BeginGetContext(GetContext, Listener);
                if (clientAccessPolicyXmlContent != null && ClientAccessPolicyXmlHandler(context)) return;
                if (crossDomainXmlContent != null && CrossDomainXmlHandler(context)) return;
                service.Handle(context);
            }
            catch(Exception e) {
                if (OnSendError != null) {
                    if (IsDebugEnabled) {
                        OnSendError(e.ToString());
                    }
                    else {
                        OnSendError(e.Message);
                    }
                }
            }
        }
    }
}
#endif