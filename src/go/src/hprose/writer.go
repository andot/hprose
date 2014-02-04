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
 * LastModified: Feb 4, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"math/big"
	"reflect"
	"time"
)

type BufWriter interface {
	Write(p []byte) (n int, err error)
	WriteByte(c byte) error
	WriteRune(r rune) (n int, err error)
	WriteString(s string) (n int, err error)
}

type Writer interface {
	Stream() BufWriter
	Serialize(interface{}) error
	WriteValue(reflect.Value) error
	WriteNull() error
	WriteInt64(int64) error
	WriteUint64(uint64) error
	WriteBigInt(*big.Int) error
	WriteFloat64(float64) error
	WriteBool(bool) error
	WriteTime(time.Time) error
	WriteString(string) error
	WriteStringWithRef(string) error
	WriteBytes([]byte) error
	WriteBytesWithRef([]byte) error
	WriteArray([]reflect.Value) error
	Reset()
}

type writerRefer interface {
	setRef(v interface{})
	writeRef(w *writer, v interface{}) (success bool, err error)
	resetRef()
}

type realWriterRefer struct {
	ref map[interface{}]int
}

func (r *realWriterRefer) setRef(v interface{}) {
	if r.ref == nil {
		r.ref = make(map[interface{}]int)
	}
	n := len(r.ref)
	r.ref[v] = n
}

func (r *realWriterRefer) writeRef(w *writer, v interface{}) (success bool, err error) {
	if n, found := r.ref[v]; found {
		s := w.stream
		if err = s.WriteByte(TagRef); err == nil {
			if err = w.writeInt(n); err == nil {
				err = s.WriteByte(TagSemicolon)
			}
		}
		return true, err
	}
	return false, nil
}

func (r *realWriterRefer) resetRef() {
	if r.ref != nil {
		r.ref = nil
	}
}

func NewWriter(stream BufWriter) Writer {
	return &writer{
		stream:      stream,
		writerRefer: &realWriterRefer{},
	}
}
