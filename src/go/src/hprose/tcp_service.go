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
 * hprose/tcp_service.go                                  *
 *                                                        *
 * hprose tcp service for Go.                             *
 *                                                        *
 * LastModified: Feb 1, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bufio"
	"net"
	"net/url"
)

type TcpService struct {
	*BaseService
}

func NewTcpService() *TcpService {
	return &TcpService{NewBaseService()}
}

func (service *TcpService) ServeTCP(conn net.Conn) {
	istream := bufio.NewReader(conn)
	ostream := bufio.NewWriter(conn)
	go func() {
		for {
			service.Handle(istream, ostream)
			if service.IOError != nil {
				service.IOError = nil
				conn.Close()
				break
			}
			ostream.Flush()
		}
	}()
}

type TcpServer struct {
	*TcpService
	URL string
	net.Listener
}

func NewTcpServer(uri string) *TcpServer {
	if uri == "" {
		uri = "tcp://127.0.0.1:0"
	}
	var u *url.URL
	var err error
	if u, err = url.Parse(uri); err != nil {
		panic(err.Error())
	}
	var addr *net.TCPAddr
	if addr, err = net.ResolveTCPAddr(u.Scheme, u.Host); err != nil {
		panic(err.Error())
	}
	var listener net.Listener
	if listener, err = net.ListenTCP(u.Scheme, addr); err != nil {
		panic(err.Error())
	}
	return &TcpServer{NewTcpService(), u.Scheme + "://" + listener.Addr().String(), listener}
}

func (server *TcpServer) Start() (err error) {
	for {
		var conn net.Conn
		if conn, err = server.Listener.Accept(); err != nil {
			return err
		}
		server.ServeTCP(conn)
	}
}
