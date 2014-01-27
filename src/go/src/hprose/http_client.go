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
 * LastModified: Jan 28, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bytes"
	"io/ioutil"
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
	client           *http.Client
	keepAlive        bool
	keepAliveTimeout int
}

type httpContext struct {
	uri     string
	istream *bytes.Buffer
}

func NewHttpClient(uri string) Client {
	if u, err := url.Parse(uri); err == nil {
		if u.Scheme != "http" && u.Scheme != "https" {
			panic("This client desn't support " + u.Scheme + " scheme.")
		}
	} else {
		panic("The uri can't be parsed.")
	}
	return NewBaseClient(uri, newHttpTransporter())
}

func (client *HttpClient) KeepAlive() bool {
	return client.transporter.(*httpTransporter).keepAlive
}

func (client *HttpClient) SetKeepAlive(enable bool) {
	client.transporter.(*httpTransporter).keepAlive = enable
}

func (client *HttpClient) KeepAliveTimeout() int {
	return client.transporter.(*httpTransporter).keepAliveTimeout
}

func (client *HttpClient) SetKeepAliveTimeout(timeout int) {
	client.transporter.(*httpTransporter).keepAliveTimeout = timeout
}

func newHttpTransporter() *httpTransporter {
	return &httpTransporter{&http.Client{Jar: cookieJar}, false, 300}
}

func (h *httpTransporter) GetInvokeContext(uri string) (interface{}, error) {
	return &httpContext{uri: uri}, nil
}

func (h *httpTransporter) GetOutputStream(context interface{}) (*bytes.Buffer, error) {
	return new(bytes.Buffer), nil
}

func (h *httpTransporter) SendData(ostream *bytes.Buffer, context interface{}, success bool) error {
	if success {
		context := context.(*httpContext)
		req, err := http.NewRequest("POST", context.uri, ostream)
		if err != nil {
			return err
		}
		req.Header.Set("Content-Type", "application/hprose")
		if h.keepAlive {
			req.Header.Set("Connection", "keep-alive")
			req.Header.Set("Keep-Alive", strconv.Itoa(h.keepAliveTimeout))
		}
		resp, err := h.client.Do(req)
		if err != nil {
			return err
		}
		buf, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return err
		}
		if err = resp.Body.Close(); err != nil {
			return err
		}
		context.istream = bytes.NewBuffer(buf)
	}
	return nil
}

func (h *httpTransporter) GetInputStream(context interface{}) (*bytes.Buffer, error) {
	return context.(*httpContext).istream, nil
}

func (h *httpTransporter) EndInvoke(istream *bytes.Buffer, context interface{}, success bool) error {
	return nil
}
