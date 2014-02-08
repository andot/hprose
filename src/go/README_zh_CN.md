Hprose for Golang 使用指南
---------------------------

### Http 服务器 ###

Hprose for Golang 使用起来很简单，你可以像这样来创建一个 Hprose 的 http 服务:

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

你可以发布多值返回函数和方法，多值返回结果会自动转换为一个数组类型的结果。

### Http 客户端 ###

#### 同步调用 ####

然后你可以创建一个 Hprose 的 http 客户端来调用它了，就像这样：

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

#### 同步异常处理 ####

客户端接口通过 struct 的函数字段的方式来定义，这些函数接口不需要完全跟服务器端的接口一致，例如：

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

如果服务器端返回一个错误（必须是通过最后一个输出参数），或者是服务器端产生了 panic（在其他的语言中就是抛出异常），客户端将会收到它。如果客户端函数接口中包含有一个错误输出参数（也必须是最后一个），你可以通过它来得到服务器端的错误或 panic（异常）。如果客户端没有定义错误输出参数，那么客户端在收到服务器端错误或 panic（异常）之后，将会在客户端产生 panic。

#### 异步调用 ####

Hprose for golang 支持 golang 风格的异步调用。它不需要回调函数，但是需要定义通道型的输出参数。例如：

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

#### 异步异常处理 ####

当使用异步调用时，你需要定义一个 <code>&lt;-chan error</code> 型的输出参数（也必须是最后一个）来接收服务器端的错误和 panic（或其它语言中的异常）。如果你省略了该参数，客户端也会忽略异常，就像从来没发生过一样。

例如：

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

你将会得到结果 <code>0</code>，并且不会知道发生了什么。

#### 函数/方法 别名 ####

Golang 本身不支持函数/方法的重载，但是其它一些语言支持。所以 Hprose 提供了 “函数/方法 别名” 来调用其它语言中的重载方法。你也可以使用它来通过不同的名字来调用同一个函数或方法。

例如：

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

远程方法或函数的真实名字在函数字段的 tag 中指定就可以了。

#### 引用参数传递 ####

Hprose 还支持引用参数传递。在进行引用参数传递时，参数必须是指针类型（因为非指针类型没法被修改）。开启该选项也是通过在函数字段的 tag 中指定的。例如：

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

这个例子中的服务器是用PHP编写的。实际上，你可以使用任何 Hprose 支持的语言来编写服务器，对于客户端调用上没有区别。

### Hprose 代理 ###

你可以通过 Hprose 服务器和客户端来为 Hprose 创建代理服务器。所有的发送到 Hprose 代理服务器上的请求都将被转发到后端的 hprose 服务器上。例如：

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

不管是否定义了错误输出参数，异常都会被自动转发。

#### 更好的代理 ####

Hprose 提供了结果模式选项来改进代理服务器的性能。你可以像这样来使用它：

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

客户端结果模式选项在函数字段的 tag 中设置，客户端接口的返回值必须是 <code>[]byte</code> 类型。服务器端的结果模式选项在 <code>AddMethods</code> 方法的参数中设置（其它几个 AddXXX 方法同样可以设置这个参数）。

结果模式包含有四个值：
* Normal
* Serialized
* Raw
* RawWithEndTag

<code>Normal</code> 是默认值。

在 <code>Serialized</code> 结果模式下，返回值是一个hprose序列化的数据，以<code>[]byte</code> 类型返回，（即对返回结果不做解析）。但是参数和异常将被解析为正常值。

在 <code>Raw</code> 结果模式下，所有的应答信息都将直接以 <code>[]byte</code> 类型返回。但结果数据中不包含 Hprose 终结符。

<code>RawWithEndTag</code> 与 <code>Raw</code> 模式类似，但是它包含 Hprose 终结符。

通过结果模式选项，你可以以原始格式来存储，缓存和转发结果数据。

如果你愿意的话，你还可以将 Hprose 结合 memcache 之类的服务来实现更高效率的 Hprose 代理服务器。

> 注：客户端和服务器端的结果模式是相互独立的，你不需要同时在服务器端和客户端开启结果模式，只在一边设置为结果模式仍然可以正常通讯，不会有任何影响。

### 简单模式 ###

在默认情况下，在客户端和服务器端传输的数据是可以包含有内部引用的复杂数据，这样可以解决用 json 格式无法传递的循环引用数据的问题，同时引用对于复杂数据来说可以起到有效的压缩效果。但如果你的数据没有包含内部引用，那么你可以开启简单模式来进一步改善性能。

你可以像这样在服务器端开启简单模式：

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

选项参数 <code>true</code> 表示打开简单模式开关，这样结果将以简单模式返回给客户端。

在客户端可以这样打开简单模式：

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

在开启简单模式的情况下，参数将以简单模式传递给服务器。

> 注：客户端和服务器端的简单模式也是相互独立的，你不需要同时在服务器端和客户端开启简单模式，只在一边设置为简单模式仍然可以正常通讯，不会有任何影响。

### Missing Method ###

Hprose 支持发布一个特殊的方法：MissingMethod。所有对没有显示发布的方法的调用都讲被重定向到它上面。例如：

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

如果你想返回一个错误给客户端，请使用panic。因为在该方法中返回的 error 类型数据不会被特殊处理。

简单模式和结果模式也可以在它上面使用，因此通过它你可以构建更通用的 Hprose 代理服务器。

对客户端来说，调用 Missing Method 发布的方法跟调用普通方法没有任何区别。例如：

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

结果为：

<pre>
3
-1
2
0
0 The method 'Power' is not implemented.
</pre>

### TCP 服务器和客户端 ###

Hprose for Golang 已经支持 TCP 的服务器和客户端。它跟 HTTP 版本的服务器和客户端在使用上一样简单。

你可以使用 <code>NewTcpService</code> 或 <code>NewTcpServer</code>，来创建 Hprose 的 TCP 服务器。

使用 <code>NewTcpService</code>，你需要调用它的 <code>ServeTCP</code> 方法传入 TCP 连接。

使用 <code>NewTcpServer</code> 比 <code>NewTcpService</code> 则要简单的多。例如：
<pre lang="go">
	...
	server := hprose.NewTcpServer("tcp://127.0.0.1:1234/")
	server.AddFunction("hello", hello)
	server.Start()
	...
</pre>

创建 Hprose 的 TCP 客户端跟 HTTP 客户端是一样的方式：

<pre lang="go">
	...
	client := hprose.NewClient("tcp://127.0.0.1:1234/")
	...
</pre>

你也可以指定 <code>tcp4://</code> 方案来使用 ipv4 或 <code>tcp6://</code> 方案来使用 ipv6。

### 服务事件 ###

Hprose 定义了一个 <code>ServiceEvent</code> 接口。

<pre lang="go">
type ServiceEvent interface {
	OnBeforeInvoke(name string, args []reflect.Value, byref bool)
	OnAfterInvoke(name string, args []reflect.Value, byref bool, result []reflect.Value)
	OnSendError(err error)
}
</pre>

如果你想针对服务器的一些行为做日志的话，你可以实现这个接口，例如：

<pre lang="go">
package main

import (
	"fmt"
	"hprose"
	"net/http"
	"reflect"
)

func hello(name string) string {
	return "Hello " + name + "!"
}

type myServiceEvent struct{}

func (myServiceEvent) OnBeforeInvoke(name string, args []reflect.Value, byref bool) {
	fmt.Println(name, args, byref)
}

func (myServiceEvent) OnAfterInvoke(name string, args []reflect.Value, byref bool, result []reflect.Value) {
	fmt.Println(name, args, byref, result)
}

func (myServiceEvent) OnSendError(err error) {
	fmt.Println(err)
}

func main() {
	service := hprose.NewHttpService()
	service.ServiceEvent = myServiceEvent{}
	service.AddFunction("hello", hello)
	http.ListenAndServe(":8080", service)
}
</pre>

<code>TcpService</code> 和 <code>TcpServer</code> 同样包含这个接口字段。

另外，针对 Hprose HTTP 服务器，你还可以单独实现 <code>HttpServiceEvent</code> 接口，这个接口多了一个针对 Http 头的事件。

<pre lang="go">
type HttpServiceEvent interface {
	ServiceEvent
	OnSendHeader(response http.ResponseWriter, request *http.Request)
}
</pre>

它的实现同样是赋值给 <code>service.ServiceEvent</code> 字段就可以了。
