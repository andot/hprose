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
 * HproseHttpClient.cs                                    *
 *                                                        *
 * hprose http client class for C#.                       *
 *                                                        *
 * LastModified: Aug 7, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif
using System.IO;
#if !SILVERLIGHT
using System.IO.Compression;
#elif !SL2
using System.Net.Browser;
#endif
using System.Net;
using Hprose.IO;
using System.Security.Cryptography.X509Certificates;
using System.Threading;

namespace Hprose.Client {
    public class HproseHttpClient : HproseClient {
#if (PocketPC || Smartphone || WindowsCE)
        private static CookieManager cookieManager = new CookieManager();
#elif !SL2
        private static CookieContainer cookieContainer = new CookieContainer();
#endif
        private class HttpClientContext {
            internal HttpWebRequest request;
            internal HttpWebResponse response;
            internal Timer timer;
            internal HttpClientContext(HttpWebRequest request, HttpWebResponse response) {
                this.request = request;
                this.response = response;
                this.timer = null;
            }
        }

        private string url = null;
#if !(dotNET10 || dotNET11 || dotNETCF10)
        private Dictionary<string, string> headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
#elif MONO
        private Hashtable headers = new Hashtable(StringComparer.OrdinalIgnoreCase);
#else
        private Hashtable headers = new Hashtable(new CaseInsensitiveHashCodeProvider(), new CaseInsensitiveComparer());
#endif
		private int timeout = 30000;
#if !SILVERLIGHT
        private ICredentials credentials = null;
        private bool keepAlive = false;
        private int keepAliveTimeout = 300;
        private IWebProxy proxy = null;
#if !dotNETCF10
        private string connectionGroupName = null;
#if !(dotNET10 || dotNET11 || dotNETCF20)
        private X509CertificateCollection clientCertificates = null;
#endif
#endif
#endif
        public HproseHttpClient()
            : base() {
        }

        public HproseHttpClient(string uri)
            : base(uri) {
        }

        public HproseHttpClient(HproseMode mode)
            : base(mode) {
        }

        public HproseHttpClient(string uri, HproseMode mode)
            : base(uri, mode) {
        }

        public override void UseService(string uri) {
            this.url = uri;
        }

        public void SetHeader(string name, string value) {
            string nl = name.ToLower();
            if (nl != "content-type" &&
                nl != "content-length" &&
                nl != "host") {
                if (value == null) {
                    headers.Remove(name);
                }
                else {
                    headers[name] = value;
                }
            }
        }

        public string GetHeader(string name) {
#if (dotNET10 || dotNET11 || dotNETCF10)
            return (string)headers[name];
#else
            return headers[name];
#endif
        }

        public int Timeout {
            get {
                return timeout;
            }
            set {
                timeout = value;
            }
        }

#if !SILVERLIGHT
        public ICredentials Credentials {
            get {
                return credentials;
            }
            set {
                credentials = value;
            }
        }

        public bool KeepAlive {
            get {
                return keepAlive;
            }
            set {
                keepAlive = value;
            }
        }

        public int KeepAliveTimeout {
            get {
                return keepAliveTimeout;
            }
            set {
                keepAliveTimeout = value;
            }
        }

        public IWebProxy Proxy {
            get {
                return proxy;
            }
            set {
                proxy = value;
            }
        }

#if !dotNETCF10
        public string ConnectionGroupName {
            get {
                return connectionGroupName;
            }
            set {
                connectionGroupName = value;
            }
        }
#if !(dotNET10 || dotNET11 || dotNETCF20)
        public X509CertificateCollection ClientCertificates {
            get {
                return clientCertificates;
            }
            set {
                clientCertificates = value;
            }
        }
#endif
#endif
#endif

        protected override object GetInvokeContext() {
            Uri uri = new Uri(url);
#if !SILVERLIGHT || SL2
            HttpWebRequest request = WebRequest.Create(uri) as HttpWebRequest;
#else
            HttpWebRequest request = WebRequestCreator.ClientHttp.Create(uri) as HttpWebRequest;
#endif
#if !SILVERLIGHT
            request.Timeout = timeout;
            request.SendChunked = false;
#if !(dotNET10 || dotNETCF10)
            request.ReadWriteTimeout = timeout;
#endif
            request.Credentials = credentials;
            request.ProtocolVersion = HttpVersion.Version11;
            if (proxy != null) {
                request.Proxy = proxy;
            }
            request.KeepAlive = keepAlive;
            if (keepAlive) {
                request.Headers.Set("Keep-Alive", KeepAliveTimeout.ToString());
            }
#if !dotNETCF10
            request.ConnectionGroupName = connectionGroupName;
#if !(dotNET10 || dotNET11 || dotNETCF20)
            if (clientCertificates != null) {
                request.ClientCertificates = clientCertificates;
            }
#endif
#endif
#endif
#if (dotNET10 || dotNET11 || dotNETCF10)
            foreach (DictionaryEntry header in headers) {
                request.Headers[(string)header.Key] = (string)header.Value;
            }
#else
            foreach (KeyValuePair<string, string> header in headers) {
                request.Headers[header.Key] = header.Value;
            }
#endif
#if (PocketPC || Smartphone || WindowsCE)
            request.AllowWriteStreamBuffering = true;
            request.Headers["Cookie"] = cookieManager.GetCookie(uri.Host,
                                                                uri.AbsolutePath,
                                                                uri.Scheme == "https");
#elif !SL2
            request.CookieContainer = cookieContainer;
#endif
            return new HttpClientContext(request, null);
        }

        protected override void SendData(Stream ostream, object context, bool success) {
            ostream.Flush();
            ostream.Close();
        }

        protected override void EndInvoke(Stream istream, object context, bool success) {
            HttpClientContext clientContext = (HttpClientContext)context;
            if (clientContext.timer != null) {
                clientContext.timer.Dispose();
                clientContext.timer = null;
            }
            istream.Close();
            clientContext.response.Close();
        }

#if !SILVERLIGHT
        protected override Stream GetOutputStream(object context) {
            HttpWebRequest request = ((HttpClientContext)context).request;
            request.Method = "POST";
            request.ContentType = "application/hprose";
            Stream ostream = request.GetRequestStream();
#if !(PocketPC || Smartphone || WindowsCE)
            ostream = new BufferedStream(ostream);
#endif
            return ostream;
        }

        protected override Stream GetInputStream(object context) {
            HttpClientContext httpClientContent = (HttpClientContext)context;
            HttpWebRequest request = httpClientContent.request;
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
#if (PocketPC || Smartphone || WindowsCE)
            cookieManager.SetCookie(response.Headers.GetValues("Set-Cookie"), request.RequestUri.Host);
            cookieManager.SetCookie(response.Headers.GetValues("Set-Cookie2"), request.RequestUri.Host);
#endif
            Stream istream = response.GetResponseStream();
#if !(PocketPC || Smartphone || WindowsCE)
            istream = new BufferedStream(istream);
#endif
            string contentEncoding = response.ContentEncoding.ToLower();
            if (contentEncoding.IndexOf("deflate") > -1) {
                istream = new DeflateStream(istream, CompressionMode.Decompress);
            }
            else if (contentEncoding.IndexOf("gzip") > -1) {
                istream = new GZipStream(istream, CompressionMode.Decompress);
            }
            httpClientContent.response = response;
            return istream;
        }
#endif
        protected void TimeoutHandler(object state) {
            HttpClientContext context = (HttpClientContext)state;
            if (context.response == null) {
                context.request.Abort();
            }
            else {
                context.response.Close();
            }
            context.timer.Dispose();
            context.timer = null;
        }

        protected override IAsyncResult BeginGetOutputStream(AsyncCallback callback, object context) {
            HttpWebRequest request = ((HttpClientContext)context).request;
            request.Method = "POST";
            request.ContentType = "application/hprose";
            ((HttpClientContext)context).timer = new Timer(new TimerCallback(TimeoutHandler),
                                                           context,
                                                           timeout,
                                                           0);
            return request.BeginGetRequestStream(callback, context);
        }

        protected override Stream EndGetOutputStream(IAsyncResult asyncResult) {
            HttpClientContext context = (HttpClientContext)asyncResult.AsyncState;
            Stream ostream = context.request.EndGetRequestStream(asyncResult);
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT)
            ostream = new BufferedStream(ostream);
#endif
            return ostream;
        }

        protected override IAsyncResult BeginGetInputStream(AsyncCallback callback, object context) {
            HttpClientContext httpClientContent = (HttpClientContext)context;
            return httpClientContent.request.BeginGetResponse(callback, context);
        }

        protected override Stream EndGetInputStream(IAsyncResult asyncResult) {
            HttpClientContext httpClientContent = (HttpClientContext)asyncResult.AsyncState;
            HttpWebRequest request = httpClientContent.request;
            HttpWebResponse response = (HttpWebResponse)request.EndGetResponse(asyncResult);
#if (PocketPC || Smartphone || WindowsCE)
            cookieManager.SetCookie(response.Headers.GetValues("Set-Cookie"), request.RequestUri.Host);
            cookieManager.SetCookie(response.Headers.GetValues("Set-Cookie2"), request.RequestUri.Host);
#endif
            Stream istream = response.GetResponseStream();
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT)
            istream = new BufferedStream(istream);
#endif
#if !SILVERLIGHT
            string contentEncoding = response.ContentEncoding.ToLower();
            if (contentEncoding.IndexOf("deflate") > -1) {
                istream = new DeflateStream(istream, CompressionMode.Decompress);
            }
            else if (contentEncoding.IndexOf("gzip") > -1) {
                istream = new GZipStream(istream, CompressionMode.Decompress);
            }
#endif
            httpClientContent.response = response;
            return istream;
        }
    }
}