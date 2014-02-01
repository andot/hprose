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
 * hprose/tcp_client.go                                   *
 *                                                        *
 * hprose tcp client for Go.                              *
 *                                                        *
 * LastModified: Feb 1, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bufio"
	"bytes"
	"io"
	"net"
	"net/url"
)

type TcpClient struct {
	*BaseClient
}

type TcpTransporter struct {
	net.Conn
	uri     string
	istream *bufio.Reader
	ostream *bufio.Writer
}

type TcpContext struct {
	buf *bytes.Buffer
}

func NewTcpClient(uri string) Client {
	client := &TcpClient{NewBaseClient(new(TcpTransporter))}
	client.SetUri(uri)
	return client
}

func (client *TcpClient) SetUri(uri string) {
	if u, err := url.Parse(uri); err == nil {
		if u.Scheme != "tcp" && u.Scheme != "tcp4" && u.Scheme != "tcp6" {
			panic("This client desn't support " + u.Scheme + " scheme.")
		}
	}
	client.BaseClient.SetUri(uri)
}

func (client *TcpClient) Close() {
	conn := client.Transporter.(*TcpTransporter).Conn
	if conn != nil {
		conn.Close()
		client.Transporter.(*TcpTransporter).Conn = nil
	}
}

func (t *TcpTransporter) GetInvokeContext(uri string) (interface{}, error) {
	if t.uri != uri {
		t.uri = uri
		if t.Conn != nil {
			t.Conn.Close()
			t.Conn = nil
		}
	}
	if t.Conn == nil {
		if u, err := url.Parse(uri); err == nil {
			if tcpaddr, err := net.ResolveTCPAddr(u.Scheme, u.Host); err == nil {
				if conn, err := net.DialTCP("tcp", nil, tcpaddr); err == nil {
					t.Conn = conn
					t.istream = bufio.NewReader(conn)
					t.ostream = bufio.NewWriter(conn)
				} else {
					return nil, err
				}
			} else {
				return nil, err
			}
		} else {
			return nil, err
		}
	}
	return new(TcpContext), nil
}

func (t *TcpTransporter) GetOutputStream(context interface{}) (io.Writer, error) {
	buf := new(bytes.Buffer)
	context.(*TcpContext).buf = buf
	return buf, nil
}

func (t *TcpTransporter) SendData(context interface{}, success bool) (err error) {
	if success {
		buf := context.(*TcpContext).buf.Bytes()
		if _, err = t.ostream.Write(buf); err == nil {
			err = t.ostream.Flush()
		}
		if err != nil {
			t.Close()
			t.Conn = nil
		}
	}
	return err
}

func (t *TcpTransporter) GetInputStream(context interface{}) (io.Reader, error) {
	return t.istream, nil
}

func (t *TcpTransporter) EndInvoke(context interface{}, success bool) error {
	if !success {
		t.Close()
		t.Conn = nil
	}
	return nil
}
