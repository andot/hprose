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
 * hprose/reader.go                                       *
 *                                                        *
 * hprose Reader for Go.                                  *
 *                                                        *
 * LastModified: Jan 26, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"io"
)

type Reader struct {
	*SimpleReader
	ref []interface{}
}

func NewReader(stream io.Reader) *Reader {
	r := &Reader{}
	r.SimpleReader = NewSimpleReader(stream)
	r.ref = make([]interface{}, 0, 32)
	r.setRef = func(p interface{}) {
		r.ref = append(r.ref, p)
	}
	r.readRef = func() (interface{}, error) {
		i, err := r.ReadIntWithoutTag()
		if err == nil {
			return r.ref[i], nil
		}
		return nil, err
	}
	return r
}
