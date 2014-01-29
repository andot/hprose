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
 * LastModified: Jan 29, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

/*

Here is a client example:

	package main

	import (
		"fmt"
		"hprose"
	)

	type RemoteObject struct {
		Hello               func(string) string
		HelloWithError      func(string) (string, error)               `name:"hello"`
		AsyncHello          func(string) <-chan string                 `name:"hello"`
		AsyncHelloWithError func(string) (<-chan string, <-chan error) `name:"hello"`
		Sum                 func(...int) int
		Swap                func(*map[string]string) map[string]string `name:"swapKeyAndValue" byref:"true"`
		GetUserList         func() []testUser
	}

	func main() {
		client := hprose.NewClient("http://www.hprose.com/example/")
		var ro *RemoteObject
		client.UseService(&ro)

		// If an error occurs, it will panic
		fmt.Println(ro.Hello("World"))

		// If an error occurs, an error value will be returned
		if result, err := ro.HelloWithError("World"); err == nil {
			fmt.Println(result)
		} else {
			fmt.Println(err.Error())
		}

		// If an error occurs, it will be ignored
		result := ro.AsyncHello("World")
		fmt.Println(<-result)

		// If an error occurs, an error chan will be returned
		result, err := ro.AsyncHelloWithError("World")
		if e := <-err; e == nil {
			fmt.Println(<-result)
		} else {
			fmt.Println(e.Error())
		}
		fmt.Println(ro.Sum(1, 2, 3, 4, 5))

		m := make(map[string]string)
		m["Jan"] = "January"
		m["Feb"] = "February"
		m["Mar"] = "March"
		m["Apr"] = "April"
		m["May"] = "May"
		m["Jun"] = "June"
		m["Jul"] = "July"
		m["Aug"] = "August"
		m["Sep"] = "September"
		m["Oct"] = "October"
		m["Nov"] = "November"
		m["Dec"] = "December"

		fmt.Println(m)
		mm := ro.Swap(&m)
		fmt.Println(m)
		fmt.Println(mm)

		fmt.Println(ro.GetUserList())
	}

*/

package hprose

import (
	"bytes"
	"errors"
	"fmt"
	"io"
	"net/url"
	"reflect"
	"strings"
)

type InvokeOptions struct {
	ByRef      interface{} // true, false, nil
	SimpleMode interface{} // true, false, nil
	ResultMode ResultMode
}

type Client interface {
	UseService(...interface{})
	Invoke(string, []interface{}, *InvokeOptions, interface{}) <-chan error
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
	GetOutputStream(context interface{}) (io.Writer, error)
	SendData(ostream io.Writer, context interface{}, success bool) error
	GetInputStream(context interface{}) (io.Reader, error)
	EndInvoke(istream io.Reader, context interface{}, success bool) error
}

type BaseClient struct {
	Transporter
	byref  bool
	simple bool
	filter Filter
	uri    *url.URL
}

var clientImplementations = make(map[string]func(string) Client)

func NewBaseClient(uri string, trans Transporter) *BaseClient {
	client := &BaseClient{Transporter: trans}
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
// UseService(remoteObject interface{})
// UseService(uri string, remoteObject interface{})
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
				client.createRemoteObject(arg0)
				return
			}
		}
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
			client.createRemoteObject(args[1])
		}
	}
	panic("Wrong arguments.")
}

func (client *BaseClient) Invoke(name string, args []interface{}, options *InvokeOptions, result interface{}) <-chan error {
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
		return client.asyncInvoke(name, args, options, v.Elem())
	}
	err := make(chan error, 1)
	err <- client.invoke(name, args, options, result)
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
	context, err = client.GetInvokeContext(client.Uri())
	if err == nil {
		if err = client.doOutput(context, name, args, options); err == nil {
			err = client.doIntput(context, args, options, result)
		}
	}
	return err
}

func (client *BaseClient) asyncInvoke(name string, args []interface{}, options *InvokeOptions, result reflect.Value) <-chan error {
	t := result.Type()
	t = reflect.ChanOf(reflect.BothDir, t.Elem())
	sender := reflect.MakeChan(t, 1)
	result.Set(sender)
	errChan := make(chan error, 1)
	go func() {
		r := reflect.New(t.Elem())
		err := client.invoke(name, args, options, r.Interface())
		sender.Send(r.Elem())
		errChan <- err
	}()
	return errChan
}

func (client *BaseClient) doOutput(context interface{}, name string, args []interface{}, options *InvokeOptions) (err error) {
	var ostream io.Writer
	ostream, err = client.GetOutputStream(context)
	success := false
	defer func() {
		e := client.SendData(ostream, context, success)
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
	if br, ok := options.ByRef.(bool); ok {
		byref = br
	}
	if byref && !checkRefArgs(args) {
		return errors.New("The elements in args must be pointer when options.ByRef is true.")
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
	var istream io.Reader
	istream, err = client.GetInputStream(context)
	success := false
	defer func() {
		e := client.EndInvoke(istream, context, success)
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
	buf := new(bytes.Buffer)
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
				if err = reader.ReadRawTo(buf); err != nil {
					return err
				}
				if err = setResult(result, buf); err != nil {
					return err
				}
			default:
				if err = buf.WriteByte(TagResult); err != nil {
					return err
				}
				if err = reader.ReadRawTo(buf); err != nil {
					return err
				}
			}
		case TagArgument:
			switch resultMode {
			case Normal, Serialized:
				reader.Reset()
				if err = reader.CheckTag(TagList); err == nil {
					var count int
					if count, err = reader.ReadInt(TagOpenbrace); err == nil {
						a := make([]reflect.Value, count)
						v := reflect.ValueOf(args)
						for i := 0; i < count; i++ {
							a[i] = v.Index(i).Elem().Elem()
						}
						err = reader.ReadArray(a)
					}
				}
				if err != nil {
					return err
				}
			default:
				if err = buf.WriteByte(TagArgument); err != nil {
					return err
				}
				if err = reader.ReadRawTo(buf); err != nil {
					return err
				}
			}
		case TagError:
			switch resultMode {
			case Normal, Serialized:
				reader.Reset()
				var e string
				if e, err = reader.ReadString(); err == nil {
					err = errors.New(e)
				}
				return err
			default:
				if err = buf.WriteByte(TagError); err != nil {
					return err
				}
				if err = reader.ReadRawTo(buf); err != nil {
					return err
				}
			}
		}
	}
	switch resultMode {
	case RawWithEndTag:
		if err = buf.WriteByte(TagEnd); err != nil {
			return err
		}
		fallthrough
	case Raw:
		if err = setResult(result, buf); err != nil {
			return err
		}
	}
	success = true
	return err
}

func (client *BaseClient) createRemoteObject(ro interface{}) {
	v := reflect.ValueOf(ro).Elem()
	t := v.Type()
	et := t
	if et.Kind() == reflect.Ptr {
		et = et.Elem()
	}
	objPointer := reflect.New(et)
	obj := objPointer.Elem()
	count := obj.NumField()
	for i := 0; i < count; i++ {
		f := obj.Field(i)
		if f.Kind() == reflect.Func {
			f.Set(reflect.MakeFunc(f.Type(), client.remoteMethod(f.Type(), et.Field(i))))
		}
	}
	if t.Kind() == reflect.Ptr {
		v.Set(objPointer)
	} else {
		v.Set(obj)
	}
}

func (client *BaseClient) remoteMethod(t reflect.Type, sf reflect.StructField) func(in []reflect.Value) []reflect.Value {
	switch t.NumOut() {
	case 0, 1:
		break
	case 2:
		rt0 := t.Out(0)
		rt1 := t.Out(1)
		if rt0.Kind() == reflect.Chan &&
			rt1.Kind() == reflect.Chan &&
			rt1.Elem().Kind() == reflect.Interface &&
			rt1.Elem().Name() == "error" {
			break
		}
		if rt1.Kind() == reflect.Interface &&
			rt1.Name() == "error" {
			break
		}
		fallthrough
	default:
		panic("The results for a maximum of two parameters, and one for the error or <-chan error type.")
	}
	name := getFuncName(sf)
	options := &InvokeOptions{ByRef: getByRef(sf), SimpleMode: getSimpleMode(sf), ResultMode: getResultMode(sf)}
	return func(in []reflect.Value) []reflect.Value {
		inlen := len(in)
		varlen := 0
		argc := inlen
		if t.IsVariadic() {
			argc--
			varlen = in[argc].Len()
			argc += varlen
		}
		args := make([]interface{}, argc)
		if argc > 0 {
			for i := 0; i < inlen-1; i++ {
				args[i] = in[i].Interface()
			}
			if t.IsVariadic() {
				v := in[inlen-1]
				for i := 0; i < varlen; i++ {
					args[inlen-1+i] = v.Index(i).Interface()
				}
			} else {
				args[inlen-1] = in[inlen-1].Interface()
			}
		}
		numout := t.NumOut()
		out := make([]reflect.Value, numout)
		switch numout {
		case 0:
			var result interface{}
			if err := <-client.Invoke(name, args, options, &result); err == nil {
				return out
			} else {
				panic(err.Error())
			}
		case 1:
			rt0 := t.Out(0)
			if rt0.Kind() == reflect.Chan {
				if rt0.Elem().Kind() == reflect.Interface && rt0.Elem().Name() == "error" {
					var result chan interface{}
					err := client.Invoke(name, args, options, &result)
					out[0] = reflect.ValueOf(&err).Elem()
					return out
				} else {
					rv0p := reflect.New(rt0)
					client.Invoke(name, args, options, rv0p.Interface())
					out[0] = rv0p.Elem()
					return out
				}
			} else {
				if rt0.Kind() == reflect.Interface && rt0.Name() == "error" {
					var result interface{}
					err := <-client.Invoke(name, args, options, &result)
					out[0] = reflect.ValueOf(&err).Elem()
					return out
				} else {
					rv0p := reflect.New(rt0)
					if err := <-client.Invoke(name, args, options, rv0p.Interface()); err == nil {
						out[0] = rv0p.Elem()
						return out
					} else {
						panic(err.Error())
					}
				}
			}
		case 2:
			rt0 := t.Out(0)
			rt1 := t.Out(1)
			if rt0.Kind() == reflect.Chan &&
				rt1.Kind() == reflect.Chan &&
				rt1.Elem().Kind() == reflect.Interface &&
				rt1.Elem().Name() == "error" {
				rv0p := reflect.New(rt0)
				err := client.Invoke(name, args, options, rv0p.Interface())
				out[0] = rv0p.Elem()
				out[1] = reflect.ValueOf(&err).Elem()
				return out
			}
			if rt1.Kind() == reflect.Interface &&
				rt1.Name() == "error" {
				rv0p := reflect.New(rt0)
				err := <-client.Invoke(name, args, options, rv0p.Interface())
				out[0] = rv0p.Elem()
				out[1] = reflect.ValueOf(&err).Elem()
				return out
			}
		}
		return out
	}
}

// public functions

func RegisterClientFactory(scheme string, newClient func(string) Client) {
	clientImplementations[strings.ToLower(scheme)] = newClient
}

// private functions

func isStructPointer(p interface{}) bool {
	v := reflect.ValueOf(p)
	if !v.IsValid() || v.IsNil() {
		return false
	}
	t := v.Type()
	return t.Kind() == reflect.Ptr && (t.Elem().Kind() == reflect.Struct ||
		(t.Elem().Kind() == reflect.Ptr && t.Elem().Elem().Kind() == reflect.Struct))
}

func checkRefArgs(args []interface{}) bool {
	v := reflect.ValueOf(args)
	count := len(args)
	for i := 0; i < count; i++ {
		x := v.Index(i)
		if !x.IsValid() ||
			!x.Elem().IsValid() ||
			x.Elem().Kind() != reflect.Ptr ||
			!x.Elem().Elem().IsValid() {
			return false
		}
	}
	return true
}

func setResult(result interface{}, buf *bytes.Buffer) error {
	switch result := result.(type) {
	case **bytes.Buffer:
		*result = buf
	case *[]byte:
		*result = buf.Bytes()
	default:
		return errors.New("The argument result must be a *[]byte or **bytes.Buffer if the ResultMode is different from Normal.")
	}
	return nil
}

func getFuncName(sf reflect.StructField) string {
	keys := []string{"name", "Name", "funcname", "funcName", "FuncName"}
	for _, key := range keys {
		if name := sf.Tag.Get(key); name != "" {
			return name
		}
	}
	return sf.Name
}

func getByRef(sf reflect.StructField) interface{} {
	keys := []string{"byref", "byRef", "Byref", "ByRef"}
	for _, key := range keys {
		switch strings.ToLower(sf.Tag.Get(key)) {
		case "true", "t", "1":
			return true
		case "false", "f", "0":
			return false
		}
	}
	return nil
}

func getSimpleMode(sf reflect.StructField) interface{} {
	keys := []string{"simple", "Simple", "simpleMode", "SimpleMode"}
	for _, key := range keys {
		switch strings.ToLower(sf.Tag.Get(key)) {
		case "true", "t", "1":
			return true
		case "false", "f", "0":
			return false
		}
	}
	return nil
}

func getResultMode(sf reflect.StructField) ResultMode {
	keys := []string{"result", "Result", "resultMode", "ResultMode"}
	for _, key := range keys {
		switch strings.ToLower(sf.Tag.Get(key)) {
		case "normal":
			return Normal
		case "serialized":
			return Serialized
		case "raw":
			return Raw
		case "rawwithendtag":
			return RawWithEndTag
		}
	}
	return Normal
}

func init() {
	RegisterClientFactory("http", NewHttpClient)
	RegisterClientFactory("https", NewHttpClient)
	//RegisterClientFactory("ws", NewWebSocketClient)
	//RegisterClientFactory("tcp", NewTcpClient)
}
