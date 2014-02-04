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
 * LastModified: Feb 4, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
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
	ReadRawTo(BufWriter) error
	Reset()
}

type readerRefer interface {
	setRef(p interface{})
	readRef(i int, err error) (interface{}, error)
	resetRef()
}

type realReaderRefer struct {
	ref []interface{}
}

func (r *realReaderRefer) setRef(p interface{}) {
	if r.ref == nil {
		r.ref = make([]interface{}, 0)
	}
	r.ref = append(r.ref, p)
}

func (r *realReaderRefer) readRef(i int, err error) (interface{}, error) {
	if err == nil {
		return r.ref[i], nil
	}
	return nil, err
}

func (r *realReaderRefer) resetRef() {
	if r.ref != nil {
		r.ref = nil
	}
}

func NewReader(stream BufReader) Reader {
	return &reader{
		RawReader:   &RawReader{stream: stream},
		readerRefer: &realReaderRefer{},
	}
}
