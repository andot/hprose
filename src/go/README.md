Usage of Hprose for Golang
---------------------------

### Http Server ###

Hprose for Golang is very easy to use. You can create a hprose http server like this:

<pre lang="go">
package main

import (
	"errors"
	"hprose"
	"net/http"
)

func hello(name string) string {
	return "Hello " + name + "!"
}

type myService struct{}

func (myService) Swap(a int, b int) (int, int) {
	return b, a
}

func (myService) Sum(args ...int) (int, error) {
	if len(args) &lt; 2 {
		return 0, errors.New("Requires at least two parameters")
	}
	a := args[0]
	for i := 1; i &lt; len(args); i++ {
		a += args[i]
	}
	return a, nil
}

func main() {
	service := hprose.NewHttpService()
	service.AddFunction("hello", hello)
	service.AddMethods(myService{})
	http.ListenAndServe(":8080", service)
}
</pre>

You can publish multi-valued functions/methods, the multi-valued result will be automatically converted to an array result.

### Http Client ###

#### Synchronous Invoking ####

Then you can create a hprose http client to invoke it like this:

<pre lang="go">
package main

import (
	"fmt"
	"hprose"
)

type clientStub struct {
	Hello func(string) string
	Swap  func(int, int) (int, int)
	Sum   func(...int) (int, error)
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8080/")
	var ro *clientStub
	client.UseService(&ro)
	fmt.Println(ro.Hello("World"))
	fmt.Println(ro.Swap(1, 2))
	fmt.Println(ro.Sum(1, 2, 3, 4, 5))
	fmt.Println(ro.Sum(1))
}
</pre>

#### Synchronous Exception Handling ####

Client stubs do not have exactly the same with the server-side interfaces. For example:

<pre lang="go">
package main

import (
	"fmt"
	"hprose"
)

type clientStub struct {
	Sum   func(...int) int
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8080/")
	var ro *clientStub
	client.UseService(&ro)
	fmt.Println(ro.Sum(1, 2, 3, 4, 5))
	fmt.Println(ro.Sum(1))
}
</pre>

If an error (must be the last out parameter) returned by server-side function/method, or it panics in the server-side, the client will receive it. If the client stub has an error out parameter (also must be the last one), you can get the server-side error or panic from it. If the client stub have not define an error out parameter, the client stub will panic when receive the server-side error or panic.

#### Asynchronous Invoking ####

Hprose for golang supports golang style asynchronous invoke. It does not require a callback function, but need to define the channel out parameters. for example:

<pre lang="go">
package main

import (
	"fmt"
	"hprose"
)

type clientStub struct {
	Sum func(...int) (&lt;-chan int, &lt;-chan error)
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8080/")
	var ro *clientStub
	client.UseService(&ro)
	sum, err := ro.Sum(1, 2, 3, 4, 5)
	fmt.Println(&lt;-sum, &lt;-err)
	sum, err = ro.Sum(1)
	fmt.Println(&lt;-sum, &lt;-err)
}
</pre>

#### Asynchronous Exception Handling ####

When using asynchronous invoking, you need to define a <code>&lt;-chan error</code> out parameter (also the last one) to receive the server-side error or panic (or exception in other languages). If you omit this parameter, the client will ignore the exception, like never happened.

For example:

<pre lang="go">
package main

import (
	"fmt"
	"hprose"
)

type clientStub struct {
	Sum func(...int) (&lt;-chan int)
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8080/")
	var ro *clientStub
	client.UseService(&ro)
	fmt.Println(&lt;-ro.Sum(1))
}
</pre>

You will get the result <code>0</code>, but do not know what happened.

#### Function/Method Alias ####

Golang does not support method overload, but some other languages support. So hprose provides "Function/Method Alias" to invoke overloaded methods in other languages. You can also use it to invoke the same function/method with different names.

For example:

<pre lang="go">
package main

import (
	"fmt"
	"hprose"
)

type clientStub struct {
	Hello      func(string) string
	AsyncHello func(string) &lt;-chan string `name:"hello"`
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8080/")
	var ro *clientStub
	client.UseService(&ro)
	fmt.Println(ro.Hello("Synchronous Invoking"))
	fmt.Println(&lt;-ro.AsyncHello("Asynchronous Invoking"))
}
</pre>

The real remote function/method name is specified in the function field tag.

#### Passing by reference parameters ####

Hprose supports passing by reference parameters. The parameters must be pointer types. Open this option also in the function field tag. For example:

<pre lang="go">
package main

import (
	"fmt"
	"hprose"
)

type clientStub struct {
	Swap func(*map[string]string) `name:"swapKeyAndValue" byref:"true"`
}

func main() {
	client := hprose.NewClient("http://hprose.com/example/")
	var ro *clientStub
	client.UseService(&ro)
	m := map[string]string{
		"Jan": "January",
		"Feb": "February",
		"Mar": "March",
		"Apr": "April",
		"May": "May",
		"Jun": "June",
		"Jul": "July",
		"Aug": "August",
		"Sep": "September",
		"Oct": "October",
		"Nov": "November",
		"Dec": "December",
	}
	fmt.Println(m)
	ro.Swap(&m)
	fmt.Println(m)
}
</pre>

The server of this example was written in PHP. In fact, You can use any language which hprose supported to write the server.

### Hprose Proxy ###

You can use hprose server and client to create a hprose proxy server. All requests sent to the hprose proxy server will be forwarded to the backend hprose server. For example:

<pre lang="go">
package main

import (
	"hprose"
	"net/http"
)

type proxyStub struct {
	Hello func(string) (string, error)
	Swap  func(int, int) (int, int)
	Sum   func(...int) (int)
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8080/")
	var ro *proxyStub
	client.UseService(&ro)
	service := hprose.NewHttpService()
	service.AddMethods(ro)
	http.ListenAndServe(":8181", service)
}
</pre>

Whether the definition of the error out parameter does not matter, the exception will be automatically forwarded.

#### Better Proxy ####

Hprose provides an ResultMode options to improve performance of the proxy server. You can use it like this:
<pre lang="go">
package main

import (
	"hprose"
	"net/http"
)

type proxyStub struct {
	Hello func(string) []byte   `result:"raw"`
	Swap  func(int, int) []byte `result:"raw"`
	Sum   func(...int) []byte   `result:"raw"`
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8080/")
	var ro *proxyStub
	client.UseService(&ro)
	service := hprose.NewHttpService()
	service.AddMethods(ro, hprose.Raw)
	http.ListenAndServe(":8181", service)
}
</pre>

The client result mode option is setting in the func field tag, and the return value must be <code>[]byte</code>. The server result mode option is setting by <code>AddMethods</code> parameter.

The ResultMode have 4 values:
* Normal
* Serialized
* Raw
* RawWithEndTag

The <code>Normal</code> result mode is the default value.

In <code>Serialized</code> result mode, the returned value is a hprose serialized data in []byte, but the arguments and exception will be parsed to the real value.

In <code>Raw</code> result mode, all the reply will be returned directly to the result in []byte, but the result data doesn't have the hprose end tag.

The <code>RawWithEndTag</code> is similar to the <code>Raw</code> result mode, but it has the hprose end tag.

With the ResultMode option, you can store, cache and forward the result in the original format.

### Simple Mode ###

By default, the data between the hprose client and server can be passed with internal references. if your data have no internal references, you can open the simple mode to improve performance.

You can open simple mode in server like this:
<pre lang="go">
package main

import (
	"hprose"
	"net/http"
)

func hello(name string) string {
	return "Hello " + name + "!"
}

func main() {
	service := hprose.NewHttpService()
	service.AddFunction("hello", hello, true)
	http.ListenAndServe(":8080", service)
}
</pre>

The option parameter <code>true</code> is the simple mode switch. The result will be transmitted to the client in simple mode when it is on.

To open the client simple mode is like this:
<pre lang="go">
package main

import (
	"fmt"
	"hprose"
)

type clientStub struct {
	Hello func(string) string       `simple:"true"`
	Swap  func(int, int) (int, int) `simple:"true"`
	Sum   func(...int) (int, error)
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8181/")
	var ro *clientStub
	client.UseService(&ro)
	fmt.Println(ro.Hello("World"))
	fmt.Println(ro.Swap(1, 2))
	fmt.Println(ro.Sum(1, 2, 3, 4, 5))
	fmt.Println(ro.Sum(1))
}
</pre>
The arguments will be transmitted to the server in simple mode when it is on.

### Missing Method ###

Hprose supports publishing a special method: MissingMethod. All methods not explicitly published will be redirected to the method. For example:

<pre lang="go">
package main

import (
	"hprose"
	"net/http"
	"reflect"
	"strings"
)

func hello(name string) string {
	return "Hello " + name + "!"
}

func missing(name string, args []reflect.Value) (result []reflect.Value) {
	result = make([]reflect.Value, 1)
	switch strings.ToLower(name) {
	case "add":
		result[0] = reflect.ValueOf(args[0].Interface().(int) + args[1].Interface().(int))
	case "sub":
		result[0] = reflect.ValueOf(args[0].Interface().(int) - args[1].Interface().(int))
	case "mul":
		result[0] = reflect.ValueOf(args[0].Interface().(int) * args[1].Interface().(int))
	case "div":
		result[0] = reflect.ValueOf(args[0].Interface().(int) / args[1].Interface().(int))
	default:
		panic("The method '" + name + "' is not implemented.")
	}
	return
}

func main() {
	service := hprose.NewHttpService()
	service.AddFunction("hello", hello, true)
	service.AddMissingMethod(missing, true)
	http.ListenAndServe(":8080", service)
}
</pre>

If you want return an error to the client, please use panic. The error type return value can't be processed in the method.

The simple mode and the result mode options can also be used with it.

Invoking the missing method makes no difference with the normal method. For example:
<pre lang="go">
package main

import (
	"fmt"
	"hprose"
)

type clientStub struct {
	Add   func(int, int) int
	Sub   func(int, int) int
	Mul   func(int, int) int
	Div   func(int, int) int
	Power func(int, int) (int, error)
}

func main() {
	client := hprose.NewClient("http://127.0.0.1:8080/")
	var ro *clientStub
	client.UseService(&ro)
	fmt.Println(ro.Add(1, 2))
	fmt.Println(ro.Sub(1, 2))
	fmt.Println(ro.Mul(1, 2))
	fmt.Println(ro.Div(1, 2))
	fmt.Println(ro.Power(1, 2))
}
</pre>
The result is:
<pre>
3
-1
2
0
0 The method 'Power' is not implemented.
</pre>
