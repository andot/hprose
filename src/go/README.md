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
