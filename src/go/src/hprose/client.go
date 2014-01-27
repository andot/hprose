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
 * hprose/client.go                                       *
 *                                                        *
 * hprose client for Go.                                  *
 *                                                        *
 * LastModified: Jan 27, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

/*

type Hello struct {
	Hello function(string) string
	HelloWithError function(string) (string, error) "Hello"
	AsyncHello function(string) chan string "Hello"
	AsyncHelloWithError function(string) (chan string, chan error) "Hello"
}

client := hprose.NewClient("http://www.hprose.com/example/")
var hello Hello
client.UseService(&hello)

// If an error occurs, it will panic
fmt.Println(hello.Hello("World"))

// If an error occurs, an error value will be returned
if result, err := hello.HelloWithError("World"); err != nil {
	fmt.Println(result)
} else {
	fmt.Println(err.Error())
}

// If an error occurs, it will be ignored
result := hello.AsyncHello("World")
fmt.Println(<-result)


// If an error occurs, an error chan will be returned
result, err := hello.AsyncHelloWithError("World");
if  e := <-err; e != nil {
	fmt.Println(<-result)
} else {
	fmt.Println(e.Error())
}


*/
package hprose

import (
	"bytes"
	"errors"
	"fmt"
	"io/ioutil"
	"net/url"
	"reflect"
	"strings"
)

type InvokeOptions struct {
	Byref      interface{} // true, false, nil
	SimpleMode interface{} // true, false, nil
	ResultMode ResultMode
}

type Client interface {
	UseService(...interface{})
	Invoke(string, []interface{}, *InvokeOptions, interface{}) error
	Uri() string
	SetUri(string)
	ByRef() bool
	SetByRef(bool)
	SimpleMode() bool
	SetSimpleMode(bool)
	Filter() Filter
	SetFilter(Filter)
}

type Transporter interface {
	GetInvokeContext(uri string) (interface{}, error)
	GetOutputStream(context interface{}) (*bytes.Buffer, error)
	SendData(ostream *bytes.Buffer, context interface{}, success bool) error
	GetInputStream(context interface{}) (*bytes.Buffer, error)
	EndInvoke(istream *bytes.Buffer, context interface{}, success bool) error
}

type BaseClient struct {
	byref       bool
	simple      bool
	filter      Filter
	uri         *url.URL
	transporter Transporter
}

var clientImplementations = make(map[string]func(string) Client)

func NewBaseClient(uri string, transporter Transporter) *BaseClient {
	client := &BaseClient{transporter: transporter}
	client.SetUri(uri)
	return client
}

func NewClient(uri string) Client {
	if u, err := url.Parse(uri); err == nil {
		if newClient, ok := clientImplementations[u.Scheme]; ok {
			return newClient(uri)
		}
		panic("The " + u.Scheme + "client isn't implemented.")
	} else {
		panic("The uri can't be parsed.")
	}
}

func (client *BaseClient) Uri() string {
	return client.uri.String()
}

func (client *BaseClient) SetUri(uri string) {
	if u, err := url.Parse(uri); err == nil {
		client.uri = u
	} else {
		panic("The uri can't be parsed.")
	}
}

func (client *BaseClient) ByRef() bool {
	return client.byref
}

func (client *BaseClient) SetByRef(byref bool) {
	client.byref = byref
}

func (client *BaseClient) SimpleMode() bool {
	return client.simple
}

func (client *BaseClient) SetSimpleMode(simple bool) {
	client.simple = simple
}

func (client *BaseClient) Filter() Filter {
	return client.filter
}

func (client *BaseClient) SetFilter(filter Filter) {
	client.filter = filter
}

// UseService(uri string)
// UseService(proxy interface{})
// UseService(uri string, proxy interface{})
func (client *BaseClient) UseService(args ...interface{}) {
	switch len(args) {
	case 1:
		switch arg0 := args[0].(type) {
		case nil:
			panic("The arguments can't be nil.")
		case string:
			client.SetUri(arg0)
			return
		case *string:
			client.SetUri(*arg0)
			return
		default:
			if isStructPointer(arg0) {
				client.getProxy(arg0)
				return
			}
		}
		panic("Wrong arguments.")
	case 2:
		switch arg0 := args[0].(type) {
		case nil:
			panic("The arguments can't be nil.")
		case string:
			client.SetUri(arg0)
		case *string:
			client.SetUri(*arg0)
		default:
			panic("Wrong arguments.")
		}
		if args[1] == nil {
			panic("The arguments can't be nil.")
		}
		if isStructPointer(args[1]) {
			client.getProxy(args[1])
		} else {
			panic("Wrong arguments.")
		}
	}
	panic("Wrong arguments.")
}

func (client *BaseClient) Invoke(name string, args []interface{}, options *InvokeOptions, result interface{}) (err error) {
	if result == nil {
		panic("The argument result can't be nil")
	}
	v := reflect.ValueOf(result)
	t := v.Type()
	if t.Kind() != reflect.Ptr {
		panic("The argument result must be pointer type")
	}
	if options == nil {
		options = new(InvokeOptions)
	}
	if t.Elem().Kind() == reflect.Chan {
		client.asyncInvoke(name, args, options, v.Elem())
	} else {
		err = client.invoke(name, args, options, result)
	}
	return err
}

// private methods

func (client *BaseClient) invoke(name string, args []interface{}, options *InvokeOptions, result interface{}) (err error) {
	defer func() {
		if e := recover(); e != nil && err == nil {
			err = fmt.Errorf("%v", e)
		}
	}()
	var context interface{}
	context, err = client.transporter.GetInvokeContext(client.Uri())
	if err == nil {
		if err = client.doOutput(context, name, args, options); err == nil {
			err = client.doIntput(context, args, options, result)
		}
	}
	return err
}

func (client *BaseClient) asyncInvoke(name string, args []interface{}, options *InvokeOptions, result reflect.Value) <-chan error {
	t := result.Type()
	result.Set(reflect.MakeChan(t, 1))
	errChan := make(chan error, 1)
	go func() {
		r := reflect.New(t.Elem())
		err := client.invoke(name, args, options, r.Interface())
		result.Send(r.Elem())
		errChan <- err
	}()
	return errChan
}

func (client *BaseClient) doOutput(context interface{}, name string, args []interface{}, options *InvokeOptions) (err error) {
	trans := client.transporter
	var ostream *bytes.Buffer
	ostream, err = trans.GetOutputStream(context)
	success := false
	defer func() {
		e := trans.SendData(ostream, context, success)
		if err == nil {
			err = e
		}
	}()
	if err != nil {
		return err
	}
	if client.filter != nil {
		ostream = client.filter.OutputFilter(ostream)
	}
	simple := client.simple
	if s, ok := options.SimpleMode.(bool); ok {
		simple = s
	}
	byref := client.byref
	if br, ok := options.Byref.(bool); ok {
		byref = br
	}
	var writer Writer
	if simple {
		writer = NewSimpleWriter(ostream)
	} else {
		writer = NewWriter(ostream)
	}
	if err = writer.Stream().WriteByte(TagCall); err != nil {
		return err
	}
	if err = writer.WriteString(name); err != nil {
		return err
	}
	if args != nil && (len(args) > 0 || byref) {
		writer.Reset()
		if err = writer.WriteSlice(args); err != nil {
			return err
		}
		if byref {
			if err = writer.WriteBool(true); err != nil {
				return err
			}
		}
	}
	if err = writer.Stream().WriteByte(TagEnd); err != nil {
		return err
	}
	if err = writer.Stream().Flush(); err == nil {
		success = true
	}
	return err
}

func (client *BaseClient) doIntput(context interface{}, args []interface{}, options *InvokeOptions, result interface{}) (err error) {
	trans := client.transporter
	var istream *bytes.Buffer
	istream, err = trans.GetInputStream(context)
	success := false
	defer func() {
		e := trans.EndInvoke(istream, context, success)
		if err == nil {
			err = e
		}
	}()
	if err != nil {
		return err
	}
	if client.filter != nil {
		istream = client.filter.InputFilter(istream)
	}
	resultMode := options.ResultMode
	if resultMode == RawWithEndTag ||
		resultMode == Raw {
		var buf []byte
		buf, err = ioutil.ReadAll(istream)
		if err != nil {
			return err
		}
		if resultMode == Raw {
			if buf[len(buf)-1] == TagEnd {
				buf = buf[:len(buf)-1]
			} else {
				return errors.New("wrong reply format")
			}
		}
		if err = setResult(result, buf); err != nil {
			return err
		}
	}
	reader := NewReader(istream)
	expectTags := []byte{TagResult, TagArgument, TagError, TagEnd}
	var tag byte
	for tag, err = reader.CheckTags(expectTags); err == nil && tag != TagEnd; tag, err = reader.CheckTags(expectTags) {
		switch tag {
		case TagResult:
			switch resultMode {
			case Normal:
				reader.Reset()
				if err = reader.Unserialize(result); err != nil {
					return err
				}
			case Serialized:
				var buf []byte
				if buf, err = reader.ReadRaw(); err != nil {
					return err
				}
				if err = setResult(result, buf); err != nil {
					return err
				}
			}
		case TagArgument:
			reader.Reset()
			var a []interface{}
			if err = reader.ReadSlice(&a); err == nil {
				copy(args, a)
			} else {
				return err
			}
		case TagError:
			reader.Reset()
			var e string
			if e, err = reader.ReadString(); err == nil {
				err = errors.New(e)
			}
			return err
		}
	}
	success = true
	return err
}

func (client *BaseClient) getProxy(proxy interface{}) {

}

// public functions

func RegisterClientFactory(scheme string, newClient func(string) Client) {
	clientImplementations[strings.ToLower(scheme)] = newClient
}

// private functions

func isStructPointer(v interface{}) bool {
	t := reflect.TypeOf(v)
	return t.Kind() == reflect.Ptr && t.Elem().Kind() == reflect.Struct
}

func setResult(result interface{}, buf []byte) error {
	switch result := result.(type) {
	case **bytes.Buffer:
		*result = bytes.NewBuffer(buf)
	case *[]byte:
		*result = buf
	default:
		return errors.New("The argument result must be a *[]byte or **bytes.Buffer if the ResultMode is different from Normal.")
	}
	return nil
}

func init() {
	RegisterClientFactory("http", NewHttpClient)
	//RegisterClientFactory("https", NewHttpsClient)
	//RegisterClientFactory("ws", NewWebSocketClient)
	//RegisterClientFactory("tcp", NewTcpClient)
}
