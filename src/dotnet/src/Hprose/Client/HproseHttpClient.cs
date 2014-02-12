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
 * LastModified: Jan 1, 2014                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif
using System.IO;
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
using System.IO.Compression;
#elif !(SL2 || Core)
using System.Net.Browser;
#endif
using System.Net;
using Hprose.IO;
#if !(dotNET10 || dotNET11 || dotNETCF10 || dotNETCF20 || SILVERLIGHT || WINDOWS_PHONE || Core)
using System.Security.Cryptography.X509Certificates;
#endif
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
#if !Core
            internal Timer timer;
#endif
            internal HttpClientContext(HttpWebRequest request, HttpWebResponse response) {
                this.request = request;
                this.response = response;
#if !Core
                this.timer = null;
#endif
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
#if !Core
		private int timeout = 30000;
#endif
#if !(SILVERLIGHT || WINDOWS_PHONE)
        private ICredentials credentials = null;
#if !Core
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

#if !Core
        public int Timeout {
            get {
                return timeout;
            }
            set {
                timeout = value;
            }
        }
#endif

#if !(SILVERLIGHT || WINDOWS_PHONE)
        public ICredentials Credentials {
            get {
                return credentials;
            }
            set {
                credentials = value;
            }
        }

#if !Core
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
#endif

        protected override object GetInvokeContext() {
            Uri uri = new Uri(url);
#if !(SILVERLIGHT || WINDOWS_PHONE) || SL2
            HttpWebRequest request = WebRequest.Create(uri) as HttpWebRequest;
#else
            HttpWebRequest request = WebRequestCreator.ClientHttp.Create(uri) as HttpWebRequest;
#endif
#if !(SILVERLIGHT || WINDOWS_PHONE)
            request.Credentials = credentials;
#if !Core
            request.ServicePoint.ConnectionLimit = Int32.MaxValue;
            request.Timeout = timeout;
            request.SendChunked = false;
#if !(dotNET10 || dotNETCF10)
            request.ReadWriteTimeout = timeout;
#endif
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
#if (dotNET10 || dotNET11 || dotNETCF10 || dotNETCF20)
            ostream.Close();
#else
            ostream.Dispose();
#endif
        }

        protected override void EndInvoke(Stream istream, object context, bool success) {
            HttpClientContext clientContext = (HttpClientContext)context;
#if !Core
            if (clientContext.timer != null) {
                clientContext.timer.Dispose();
                clientContext.timer = null;
            }
#endif
#if (dotNET10 || dotNET11 || dotNETCF10 || dotNETCF20)
            istream.Close();
#else
            istream.Dispose();
#endif
#if dotNET45
            clientContext.response.Dispose();
#else
            clientContext.response.Close();
#endif
        }

#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
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
#if !Core
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
#endif
        protected override IAsyncResult BeginGetOutputStream(AsyncCallback callback, object context) {
            HttpWebRequest request = ((HttpClientContext)context).request;
            request.Method = "POST";
            request.ContentType = "application/hprose";
#if !Core
            ((HttpClientContext)context).timer = new Timer(new TimerCallback(TimeoutHandler),
                                                           context,
                                                           timeout,
                                                           0);
#endif
            return request.BeginGetRequestStream(callback, context);
        }

        protected override Stream EndGetOutputStream(IAsyncResult asyncResult) {
            HttpClientContext context = (HttpClientContext)asyncResult.AsyncState;
            Stream ostream = context.request.EndGetRequestStream(asyncResult);
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
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
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
            istream = new BufferedStream(istream);
#endif
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
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