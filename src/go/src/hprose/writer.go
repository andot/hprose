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
 * LastModified: Jan 30, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bufio"
	"container/list"
	"io"
	"math/big"
	"reflect"
	"strconv"
	"time"
	"uuid"
)

type Writer interface {
	Stream() *bufio.Writer
	Serialize(interface{}) error
	WriteValue(reflect.Value) error
	WriteNull() error
	WriteInt(int) error
	WriteUint(uint) error
	WriteInt8(int8) error
	WriteUint8(uint8) error
	WriteInt16(int16) error
	WriteUint16(uint16) error
	WriteInt32(int32) error
	WriteUint32(uint32) error
	WriteInt64(int64) error
	WriteUint64(uint64) error
	WriteBigInt(*big.Int) error
	WriteFloat32(float32) error
	WriteFloat64(float64) error
	WriteNaN() error
	WriteInfinity(bool) error
	WriteBool(bool) error
	WriteTime(time.Time) error
	WriteTimeWithRef(time.Time) error
	WriteEmpty() error
	WriteUTF8Char(string) error
	WriteString(string) error
	WriteStringWithRef(string) error
	WriteBytes(*[]byte) error
	WriteBytesWithRef(*[]byte) error
	WriteUUID(*uuid.UUID) error
	WriteUUIDWithRef(*uuid.UUID) error
	WriteList(*list.List) error
	WriteListWithRef(*list.List) error
	WriteArray([]reflect.Value) error
	WriteSlice(interface{}) error
	WriteSliceWithRef(interface{}) error
	WriteMap(interface{}) error
	WriteMapWithRef(interface{}) error
	WriteObject(interface{}) error
	WriteObjectWithRef(interface{}) error
	Reset()
}

type writer struct {
	*simpleWriter
	ref map[interface{}]int
}

func NewWriter(stream io.Writer) Writer {
	w := &writer{NewSimpleWriter(stream).(*simpleWriter), make(map[interface{}]int)}
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

func (w *writer) Reset() {
	w.simpleWriter.Reset()
	w.ref = make(map[interface{}]int)
}
