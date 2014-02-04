Usage of Hprose for Golang
---------------------------

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

Client stubs do not have exactly the same with the server-side interfaces. for example:

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
