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
 * hprose/http_client.go                                  *
 *                                                        *
 * hprose http client for Go.                             *
 *                                                        *
 * LastModified: Jan 30, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bytes"
	"crypto/tls"
	"io"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"strconv"
)

var cookieJar, _ = cookiejar.New(nil)

type HttpClient struct {
	*BaseClient
}

type httpTransporter struct {
	*http.Client
	keepAlive        bool
	keepAliveTimeout int
}

type httpContext struct {
	uri  string
	buf  io.ReadWriter
	body io.ReadCloser
}

func NewHttpClient(uri string) Client {
	if u, err := url.Parse(uri); err == nil {
		if u.Scheme != "http" && u.Scheme != "https" {
			panic("This client desn't support " + u.Scheme + " scheme.")
		}
	} else {
		panic("The uri can't be parsed.")
	}
	client := &HttpClient{NewBaseClient(uri, newHttpTransporter())}
	client.SetKeepAlive(true)
	return client
}

func (client *HttpClient) TLSClientConfig() *tls.Config {
	if transport, ok := client.Http().Transport.(*http.Transport); ok {
		return transport.TLSClientConfig
	}
	return nil
}

func (client *HttpClient) SetTLSClientConfig(config *tls.Config) bool {
	transport, ok := client.Http().Transport.(*http.Transport)
	if ok {
		transport.TLSClientConfig = config
	}
	return ok
}

func (client *HttpClient) KeepAlive() bool {
	if transport, ok := client.Http().Transport.(*http.Transport); ok {
		return !transport.DisableKeepAlives
	}
	return client.Transporter.(*httpTransporter).keepAlive
}

func (client *HttpClient) SetKeepAlive(enable bool) {
	if transport, ok := client.Http().Transport.(*http.Transport); ok {
		transport.DisableKeepAlives = !enable
		client.Transporter.(*httpTransporter).keepAlive = enable
	}
}

func (client *HttpClient) KeepAliveTimeout() int {
	return client.Transporter.(*httpTransporter).keepAliveTimeout
}

func (client *HttpClient) SetKeepAliveTimeout(timeout int) {
	client.Transporter.(*httpTransporter).keepAliveTimeout = timeout
}

func (client *HttpClient) Compression() bool {
	if transport, ok := client.Http().Transport.(*http.Transport); ok {
		return !transport.DisableCompression
	}
	return false
}

func (client *HttpClient) SetCompression(enable bool) {
	if transport, ok := client.Http().Transport.(*http.Transport); ok {
		transport.DisableCompression = !enable
	}
}

func (client *HttpClient) MaxIdleConnsPerHost() int {
	if transport, ok := client.Http().Transport.(*http.Transport); ok {
		return transport.MaxIdleConnsPerHost
	}
	return http.DefaultMaxIdleConnsPerHost
}

func (client *HttpClient) SetMaxIdleConnsPerHost(value int) bool {
	transport, ok := client.Http().Transport.(*http.Transport)
	if ok {
		transport.MaxIdleConnsPerHost = value
	}
	return ok
}

func (client *HttpClient) Http() *http.Client {
	return client.Transporter.(*httpTransporter).Client
}

func newHttpTransporter() *httpTransporter {
	return &httpTransporter{&http.Client{Jar: cookieJar}, true, 300}
}

func (h *httpTransporter) GetInvokeContext(uri string) (interface{}, error) {
	return &httpContext{uri: uri, buf: new(bytes.Buffer)}, nil
}

func (h *httpTransporter) GetOutputStream(context interface{}) (io.Writer, error) {
	return context.(*httpContext).buf, nil
}

func (h *httpTransporter) SendData(context interface{}, success bool) error {
	if success {
		context := context.(*httpContext)
		req, err := http.NewRequest("POST", context.uri, context.buf)
		if err != nil {
			return err
		}
		req.Header.Set("Content-Type", "application/hprose")
		if h.keepAlive {
			req.Header.Set("Connection", "keep-alive")
			req.Header.Set("Keep-Alive", strconv.Itoa(h.keepAliveTimeout))
		}
		resp, err := h.Do(req)
		if err != nil {
			return err
		}
		context.body = resp.Body
	}
	return nil
}

func (h *httpTransporter) GetInputStream(context interface{}) (io.Reader, error) {
	return context.(*httpContext).body, nil
}

func (h *httpTransporter) EndInvoke(context interface{}, success bool) error {
	return context.(*httpContext).body.Close()
}
