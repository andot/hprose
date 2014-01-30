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

type HttpClientTransporter struct {
	*http.Client
	keepAlive        bool
	keepAliveTimeout int
}

type HttpClientContext struct {
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
	client := &HttpClient{NewBaseClient(uri, newHttpClientTransporter())}
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
	return client.ClientTransporter.(*HttpClientTransporter).keepAlive
}

func (client *HttpClient) SetKeepAlive(enable bool) {
	if transport, ok := client.Http().Transport.(*http.Transport); ok {
		transport.DisableKeepAlives = !enable
		client.ClientTransporter.(*HttpClientTransporter).keepAlive = enable
	}
}

func (client *HttpClient) KeepAliveTimeout() int {
	return client.ClientTransporter.(*HttpClientTransporter).keepAliveTimeout
}

func (client *HttpClient) SetKeepAliveTimeout(timeout int) {
	client.ClientTransporter.(*HttpClientTransporter).keepAliveTimeout = timeout
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
	return client.ClientTransporter.(*HttpClientTransporter).Client
}

func newHttpClientTransporter() *HttpClientTransporter {
	return &HttpClientTransporter{&http.Client{Jar: cookieJar}, true, 300}
}

func (h *HttpClientTransporter) GetInvokeContext(uri string) (interface{}, error) {
	return &HttpClientContext{uri: uri, buf: new(bytes.Buffer)}, nil
}

func (h *HttpClientTransporter) GetOutputStream(context interface{}) (io.Writer, error) {
	return context.(*HttpClientContext).buf, nil
}

func (h *HttpClientTransporter) SendData(context interface{}, success bool) error {
	if success {
		context := context.(*HttpClientContext)
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

func (h *HttpClientTransporter) GetInputStream(context interface{}) (io.Reader, error) {
	return context.(*HttpClientContext).body, nil
}

func (h *HttpClientTransporter) EndInvoke(context interface{}, success bool) error {
	return context.(*HttpClientContext).body.Close()
}
