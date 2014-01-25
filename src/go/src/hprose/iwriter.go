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
 * hprose/iwriter.go                                      *
 *                                                        *
 * hprose IWriter for Go.                                 *
 *                                                        *
 * LastModified: Jan 24, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bufio"
	"container/list"
	"math/big"
	"time"
	"uuid"
)

type IWriter interface {
	Stream() *bufio.Writer
	Serialize(interface{}) error
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
	WriteSlice(interface{}) error
	WriteSliceWithRef(interface{}) error
	WriteMap(interface{}) error
	WriteMapWithRef(interface{}) error
	WriteObject(interface{}) error
	WriteObjectWithRef(interface{}) error
}
