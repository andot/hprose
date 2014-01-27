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
 * hprose/client_test.go                                  *
 *                                                        *
 * hprose Client Test for Go.                             *
 *                                                        *
 * LastModified: Jan 28, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"fmt"
	"reflect"
	"testing"
	"time"
)

type testUser struct {
	Name     string
	Sex      int
	Birthday time.Time
	Age      int
	Married  bool
}

func TestClient(t *testing.T) {
	client := NewClient("http://www.hprose.com/example/")
	var r1 chan string
	if err := client.Invoke("hello", []interface{}{"world"}, nil, &r1); err != nil {
		t.Error(err.Error())
	}
	fmt.Println(<-r1)

	var r2 chan int
	if err := client.Invoke("sum", []interface{}{1, 2, 3, 4, 5, 6, 7}, nil, &r2); err != nil {
		t.Error(err.Error())
	}
	fmt.Println(<-r2)

	ClassManager.Register(reflect.TypeOf(testUser{}), "User")
	var r3 chan []testUser
	if err := client.Invoke("getUserList", []interface{}{}, nil, &r3); err != nil {
		t.Error(err.Error())
	}
	fmt.Println(<-r3)

	var r4 chan []byte
	if err := client.Invoke("hello", []interface{}{"马秉尧"}, &InvokeOptions{ResultMode: Serialized}, &r4); err != nil {
		t.Error(err.Error())
	}
	fmt.Println(string(<-r4))
	if err := client.Invoke("hello", []interface{}{"马秉尧"}, &InvokeOptions{ResultMode: Raw}, &r4); err != nil {
		t.Error(err.Error())
	}
	fmt.Println(string(<-r4))
	if err := client.Invoke("hello", []interface{}{"马秉尧"}, &InvokeOptions{ResultMode: RawWithEndTag}, &r4); err != nil {
		t.Error(err.Error())
	}
	fmt.Println(string(<-r4))

}
