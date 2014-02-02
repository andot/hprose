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
 * LastModified: Feb 3, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bytes"
	"container/list"
	"math/big"
	"reflect"
	"time"
	"uuid"
)

type BufReader interface {
	Read(p []byte) (n int, err error)
	ReadByte() (c byte, err error)
	ReadRune() (r rune, size int, err error)
	ReadString(delim byte) (line string, err error)
}

type Reader interface {
	Stream() BufReader
	CheckTag(byte) error
	CheckTags([]byte) (byte, error)
	Unserialize(interface{}) error
	ReadValue(reflect.Value) error
	ReadInteger(byte) (int, error)
	ReadUinteger(byte) (uint, error)
	ReadInt() (int, error)
	ReadUint() (uint, error)
	ReadInt8() (int8, error)
	ReadUint8() (uint8, error)
	ReadInt16() (int16, error)
	ReadUint16() (uint16, error)
	ReadInt32() (int32, error)
	ReadUint32() (uint32, error)
	ReadInt64() (int64, error)
	ReadUint64() (uint64, error)
	ReadBigInt() (*big.Int, error)
	ReadFloat32() (float32, error)
	ReadFloat64() (float64, error)
	ReadBool() (bool, error)
	ReadDateTime() (time.Time, error)
	ReadDateWithoutTag() (time.Time, error)
	ReadTimeWithoutTag() (time.Time, error)
	ReadString() (string, error)
	ReadStringWithoutTag() (string, error)
	ReadBytes() (*[]byte, error)
	ReadBytesWithoutTag() (*[]byte, error)
	ReadUUID() (*uuid.UUID, error)
	ReadUUIDWithoutTag() (*uuid.UUID, error)
	ReadList() (*list.List, error)
	ReadListWithoutTag() (*list.List, error)
	ReadArray([]reflect.Value) error
	ReadSlice(interface{}) error
	ReadSliceWithoutTag(interface{}) error
	ReadMap(interface{}) error
	ReadMapWithoutTag(interface{}) error
	ReadObject(interface{}) error
	ReadObjectWithoutTag(interface{}) error
	ReadRaw() ([]byte, error)
	ReadRawTo(*bytes.Buffer) error
	Reset()
}

type reader struct {
	*simpleReader
	ref []interface{}
}

func NewReader(stream BufReader) Reader {
	r := &reader{}
	r.simpleReader = NewSimpleReader(stream).(*simpleReader)
	r.setRef = r.readerSetRef
	r.readRef = r.readerReadRef
	return r
}

func (r *reader) readerSetRef(p interface{}) {
	if r.ref == nil {
		r.ref = make([]interface{}, 0, 32)
	}
	r.ref = append(r.ref, p)
}

func (r *reader) readerReadRef() (interface{}, error) {
	i, err := r.ReadInteger(TagSemicolon)
	if err == nil {
		return r.ref[i], nil
	}
	return nil, err
}

func (r *reader) Reset() {
	r.simpleReader.Reset()
	r.ref = r.ref[:0]
}
