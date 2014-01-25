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
 * hprose/writer.go                                       *
 *                                                        *
 * hprose Writer for Go.                                  *
 *                                                        *
 * LastModified: Jan 24, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"io"
	"strconv"
)

type Writer struct {
	*SimpleWriter
	ref map[interface{}]int
}

func NewWriter(stream io.Writer) *Writer {
	w := &Writer{NewSimpleWriter(stream), make(map[interface{}]int)}
	w.setRef = func(v interface{}) {
		n := len(w.ref)
		w.ref[v] = n
	}
	w.writeRef = func(v interface{}) (success bool, err error) {
		if n, found := w.ref[v]; found {
			s := w.stream
			if err = s.WriteByte(TagRef); err == nil {
				if _, err = s.WriteString(strconv.Itoa(n)); err == nil {
					err = s.WriteByte(TagSemicolon)
				}
			}
			return true, err
		}
		return false, nil
	}
	return w
}
