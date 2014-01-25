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
 * hprose/ireader.go                                      *
 *                                                        *
 * hprose IReader for Go.                                 *
 *                                                        *
 * LastModified: Jan 26, 2014                             *
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

type IReader interface {
	Stream() *bufio.Reader
	CheckTag(byte) error
	CheckTags([]byte) (byte, error)
	Unserialize(interface{}) error
	ReadInt() (int64, error)
	ReadUint() (uint64, error)
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
	ReadSlice(interface{}) error
	ReadSliceWithoutTag(interface{}) error
	ReadMap(interface{}) error
	ReadMapWithoutTag(interface{}) error
	ReadObject(interface{}) error
	ReadObjectWithoutTag(interface{}) error
}
