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
 * LastModified: Feb 2, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bufio"
	"bytes"
	"crypto/tls"
	"net"
	"net/url"
	"time"
)

type TcpClient struct {
	*BaseClient
	deadline        interface{}
	keepAlive       interface{}
	keepAlivePeriod interface{}
	linger          interface{}
	noDelay         interface{}
	readBuffer      interface{}
	readDeadline    interface{}
	writerBuffer    interface{}
	writerDeadline  interface{}
	config          *tls.Config
}

type TcpTransporter struct {
	net.Conn
	uri     string
	istream *bufio.Reader
	*TcpClient
}

type TcpContext struct {
	buf *bytes.Buffer
}

func NewTcpClient(uri string) Client {
	client := &TcpClient{BaseClient: NewBaseClient(new(TcpTransporter))}
	client.Transporter.(*TcpTransporter).TcpClient = client
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

func (client *TcpClient) SetDeadline(t time.Time) {
	client.deadline = t
}

func (client *TcpClient) SetKeepAlive(keepalive bool) {
	client.keepAlive = keepalive
}

func (client *TcpClient) SetKeepAlivePeriod(d time.Duration) {
	client.keepAlivePeriod = d
}

func (client *TcpClient) SetLinger(sec int) {
	client.linger = sec
}

func (client *TcpClient) SetNoDelay(noDelay bool) {
	client.noDelay = noDelay
}

func (client *TcpClient) SetReadBuffer(bytes int) {
	client.readBuffer = bytes
}

func (client *TcpClient) SetReadDeadline(t time.Time) {
	client.readDeadline = t
}

func (client *TcpClient) SetWriteBuffer(bytes int) {
	client.writerBuffer = bytes
}

func (client *TcpClient) SetWriteDeadline(t time.Time) {
	client.writerDeadline = t
}

func (client *TcpClient) SetTLSConfig(config *tls.Config) {
	client.config = config
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
					if t.keepAlive != nil {
						if err := conn.SetKeepAlive(t.keepAlive.(bool)); err != nil {
							return nil, err
						}
					}
					if t.keepAlivePeriod != nil {
						if err := conn.SetKeepAlivePeriod(t.keepAlivePeriod.(time.Duration)); err != nil {
							return nil, err
						}
					}
					if t.linger != nil {
						if err := conn.SetLinger(t.linger.(int)); err != nil {
							return nil, err
						}
					}
					if t.noDelay != nil {
						if err := conn.SetNoDelay(t.noDelay.(bool)); err != nil {
							return nil, err
						}
					}
					if t.readBuffer != nil {
						if err := conn.SetReadBuffer(t.readBuffer.(int)); err != nil {
							return nil, err
						}
					}
					if t.writerBuffer != nil {
						if err := conn.SetWriteBuffer(t.writerBuffer.(int)); err != nil {
							return nil, err
						}
					}
					if t.deadline != nil {
						if err := conn.SetDeadline(t.deadline.(time.Time)); err != nil {
							return nil, err
						}
					}
					if t.readDeadline != nil {
						if err := conn.SetReadDeadline(t.readDeadline.(time.Time)); err != nil {
							return nil, err
						}
					}
					if t.writerDeadline != nil {
						if err := conn.SetWriteDeadline(t.writerDeadline.(time.Time)); err != nil {
							return nil, err
						}
					}
					if t.config != nil {
						t.Conn = tls.Client(conn, t.config)
					} else {
						t.Conn = conn
					}
					t.istream = bufio.NewReader(t.Conn)
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

func (t *TcpTransporter) SendData(context interface{}, data []byte, success bool) (err error) {
	if success {
		if _, err = t.Conn.Write(data); err != nil {
			t.Conn.Close()
			t.Conn = nil
		}
	}
	return err
}

func (t *TcpTransporter) GetInputStream(context interface{}) (BufReader, error) {
	return t.istream, nil
}

func (t *TcpTransporter) EndInvoke(context interface{}, success bool) error {
	if !success {
		t.Conn.Close()
		t.Conn = nil
	}
	return nil
}
