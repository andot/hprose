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
 * hprose/simple_reader.go                                *
 *                                                        *
 * hprose SimpleReader for Go.                            *
 *                                                        *
 * LastModified: Jan 26, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bufio"
	"container/list"
	"errors"
	"io"
	"math"
	"math/big"
	"reflect"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
	"uuid"
)

var badEncodeError = errors.New("bad utf-8 encoding")
var NilError = errors.New("nil")
var refError = unexpectedTag(TagRef, nil)

var bigDigit = [...]*big.Int{
	big.NewInt(0),
	big.NewInt(1),
	big.NewInt(2),
	big.NewInt(3),
	big.NewInt(4),
	big.NewInt(5),
	big.NewInt(6),
	big.NewInt(7),
	big.NewInt(8),
	big.NewInt(9),
}
var bigTen = big.NewInt(10)

const timeStringFormat = "2006-01-02 15:04:05.999999999 -0700 MST"

var timeZero = time.Date(1, 1, 1, 0, 0, 0, 0, time.UTC)

type simpleReader struct {
	*RawReader
	classref  []reflect.Type
	fieldsref [][]string
	setRef    func(p interface{})
	readRef   func() (interface{}, error)
}

func NewSimpleReader(stream io.Reader) Reader {
	r := &simpleReader{}
	r.RawReader = NewRawReader(stream)
	r.classref = make([]reflect.Type, 0, 16)
	r.fieldsref = make([][]string, 0, 16)
	r.setRef = func(p interface{}) {}
	r.readRef = func() (interface{}, error) {
		return nil, refError
	}
	return r
}

func (r *simpleReader) Stream() *bufio.Reader {
	return r.stream
}

func (r *simpleReader) CheckTag(expectTag byte) error {
	tag, err := r.stream.ReadByte()
	if err == nil {
		return unexpectedTag(tag, []byte{expectTag})
	}
	return err
}

func (r *simpleReader) CheckTags(expectTags []byte) (tag byte, err error) {
	tag, err = r.stream.ReadByte()
	if err == nil {
		if err = unexpectedTag(tag, expectTags); err == nil {
			return tag, nil
		}
	}
	return 0, err
}

func (r *simpleReader) Unserialize(p interface{}) error {
	v, err := r.checkPointer(p)
	if err == nil {
		return r.unserialize(v.Elem())
	}
	return err
}

func (r *simpleReader) ReadInt() (int64, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return int64(tag - '0'), nil
		case TagInteger, TagLong:
			return r.ReadIntWithoutTag()
		case TagDouble:
			f, err := r.ReadFloat64WithoutTag()
			return int64(f), err
		case TagNull:
			return 0, NilError
		case TagEmpty, TagFalse:
			return 0, nil
		case TagTrue:
			return 1, nil
		case TagUTF8Char:
			r, _, err := s.ReadRune()
			return int64(r), err
		case TagString:
			var str string
			if str, err = r.ReadStringWithoutTag(); err == nil {
				return strconv.ParseInt(str, 10, 64)
			}
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(string); ok {
					return strconv.ParseInt(ref, 10, 64)
				}
				return 0, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type int64")
			}
		default:
			return 0, convertError(tag, "int64")
		}
	}
	return 0, err
}

func (r *simpleReader) ReadIntWithoutTag() (int64, error) {
	return r.readInt64(TagSemicolon)
}

func (r *simpleReader) ReadUint() (uint64, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return uint64(tag - '0'), nil
		case TagInteger, TagLong:
			return r.ReadUintWithoutTag()
		case TagDouble:
			f, err := r.ReadFloat64WithoutTag()
			return uint64(f), err
		case TagNull:
			return 0, NilError
		case TagEmpty, TagFalse:
			return 0, nil
		case TagTrue:
			return 1, nil
		case TagUTF8Char:
			r, _, err := s.ReadRune()
			return uint64(r), err
		case TagString:
			var str string
			if str, err = r.ReadStringWithoutTag(); err == nil {
				return strconv.ParseUint(str, 10, 64)
			}
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(string); ok {
					return strconv.ParseUint(ref, 10, 64)
				}
				return 0, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type uint64")
			}
		default:
			return 0, convertError(tag, "uint64")
		}
	}
	return 0, err
}

func (r *simpleReader) ReadUintWithoutTag() (uint64, error) {
	return r.readUint64(TagSemicolon)
}

func (r *simpleReader) ReadBigInt() (*big.Int, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return big.NewInt(int64(tag - '0')), nil
		case TagInteger, TagLong:
			return r.ReadBigIntWithoutTag()
		case TagDouble:
			f, err := r.ReadFloat64WithoutTag()
			return big.NewInt(int64(f)), err
		case TagNull:
			return big.NewInt(0), NilError
		case TagEmpty, TagFalse:
			return big.NewInt(0), nil
		case TagTrue:
			return big.NewInt(1), nil
		case TagUTF8Char:
			r, _, err := s.ReadRune()
			return big.NewInt(int64(r)), err
		case TagString:
			var str string
			if str, err = r.ReadStringWithoutTag(); err == nil {
				return stringToBigInt(str)
			}
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(string); ok {
					return stringToBigInt(ref)
				}
				return nil, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type big.Int")
			}
		default:
			return nil, convertError(tag, "big.Int")
		}
	}
	return nil, err
}

func (r *simpleReader) ReadBigIntWithoutTag() (*big.Int, error) {
	s := r.stream
	tag := TagSemicolon
	i := big.NewInt(0)
	b, err := s.ReadByte()
	if err == nil && b == tag {
		return i, nil
	}
	if err != nil {
		return i, err
	}
	pos := true
	switch b {
	case '-':
		pos = false
		fallthrough
	case '+':
		b, err = s.ReadByte()
	}
	for b != tag && err == nil {
		i = i.Mul(i, bigTen)
		i = i.Add(i, bigDigit[b-'0'])
		b, err = s.ReadByte()
	}
	if !pos {
		i = i.Neg(i)
	}
	return i, err
}

func (r *simpleReader) ReadFloat32() (float32, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return float32(tag - '0'), nil
		case TagInteger, TagLong:
			return r.readIntAsFloat32(TagSemicolon)
		case TagDouble:
			return r.ReadFloat32WithoutTag()
		case TagNull:
			return 0, NilError
		case TagEmpty, TagFalse:
			return 0, nil
		case TagTrue:
			return 1, nil
		case TagNaN:
			return float32(math.NaN()), nil
		case TagInfinity:
			f, err := r.readInfinity()
			return float32(f), err
		case TagUTF8Char:
			r, _, err := s.ReadRune()
			return float32(r), err
		case TagString:
			var str string
			if str, err = r.ReadStringWithoutTag(); err == nil {
				f, err := strconv.ParseFloat(str, 32)
				return float32(f), err
			}
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(string); ok {
					f, err := strconv.ParseFloat(ref, 32)
					return float32(f), err
				}
				return 0, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type float32")
			}
		default:
			return 0, convertError(tag, "float32")
		}
	}
	return 0, err
}

func (r *simpleReader) ReadFloat32WithoutTag() (float32, error) {
	if str, err := r.readUntil(TagSemicolon); err == nil {
		f, _ := strconv.ParseFloat(str, 32)
		return float32(f), nil
	} else {
		return float32(math.NaN()), err
	}
}
func (r *simpleReader) ReadFloat64() (float64, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return float64(tag - '0'), nil
		case TagInteger, TagLong:
			return r.readIntAsFloat64(TagSemicolon)
		case TagDouble:
			return r.ReadFloat64WithoutTag()
		case TagNull:
			return 0, NilError
		case TagEmpty, TagFalse:
			return 0, nil
		case TagTrue:
			return 1, nil
		case TagNaN:
			return math.NaN(), nil
		case TagInfinity:
			return r.readInfinity()
		case TagUTF8Char:
			r, _, err := s.ReadRune()
			return float64(r), err
		case TagString:
			var str string
			if str, err = r.ReadStringWithoutTag(); err == nil {
				return strconv.ParseFloat(str, 64)
			}
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(string); ok {
					return strconv.ParseFloat(ref, 64)
				}
				return 0, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type float64")
			}
		default:
			return 0, convertError(tag, "float64")
		}
	}
	return 0, err
}

func (r *simpleReader) ReadFloat64WithoutTag() (float64, error) {
	if str, err := r.readUntil(TagSemicolon); err == nil {
		f, _ := strconv.ParseFloat(str, 64)
		return f, nil
	} else {
		return math.NaN(), err
	}
}

func (r *simpleReader) ReadBool() (bool, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0':
			return false, nil
		case '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return true, nil
		case TagInteger, TagLong:
			i, err := r.ReadIntWithoutTag()
			return i != 0, err
		case TagDouble:
			f, err := r.ReadFloat64WithoutTag()
			return f != 0, err
		case TagNull:
			return false, NilError
		case TagEmpty, TagFalse:
			return false, nil
		case TagTrue, TagNaN:
			return true, nil
		case TagInfinity:
			_, err = r.readInfinity()
			return true, err
		case TagUTF8Char:
			var str string
			if str, err = r.readUTF8String(1); err == nil {
				return strconv.ParseBool(str)
			}
		case TagString:
			var str string
			if str, err = r.ReadStringWithoutTag(); err == nil {
				return strconv.ParseBool(str)
			}
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(string); ok {
					return strconv.ParseBool(ref)
				}
				return false, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type bool")
			}
		default:
			return false, convertError(tag, "bool")
		}
	}
	return false, err
}

func (r *simpleReader) ReadDateTime() (time.Time, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0', TagEmpty:
			return timeZero, nil
		case TagNull:
			return timeZero, NilError
		case TagString:
			var str string
			if str, err = r.ReadStringWithoutTag(); err == nil {
				return time.Parse(timeStringFormat, str)
			}
		case TagDate:
			return r.ReadDateWithoutTag()
		case TagTime:
			return r.ReadTimeWithoutTag()
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				switch ref := ref.(type) {
				case time.Time:
					return ref, nil
				case string:
					return time.Parse(timeStringFormat, ref)
				default:
					return timeZero, errors.New("cannot convert type " +
						reflect.TypeOf(ref).String() + " to type time.Time")
				}
			}
		default:
			return timeZero, convertError(tag, "time.Time")
		}
	}
	return timeZero, err
}

func (r *simpleReader) ReadDateWithoutTag() (time.Time, error) {
	s := r.stream
	var year, month, day, hour, min, sec, nsec int
	tag, err := s.ReadByte()
	if err == nil {
		year = int(tag - '0')
		if tag, err = s.ReadByte(); err == nil {
			year *= 10
			year += int(tag - '0')
			if tag, err = s.ReadByte(); err == nil {
				year *= 10
				year += int(tag - '0')
				if tag, err = s.ReadByte(); err == nil {
					year *= 10
					year += int(tag - '0')
					if tag, err = s.ReadByte(); err == nil {
						month = int(tag - '0')
						if tag, err = s.ReadByte(); err == nil {
							month *= 10
							month += int(tag - '0')
							if tag, err = s.ReadByte(); err == nil {
								day = int(tag - '0')
								if tag, err = s.ReadByte(); err == nil {
									day *= 10
									day += int(tag - '0')
									tag, err = s.ReadByte()
								}
							}
						}
					}
				}
			}
		}
	}
	if err != nil {
		return timeZero, err
	}
	if tag == TagTime {
		if hour, min, sec, nsec, tag, err = r.readTime(); err != nil {
			return timeZero, err
		}
	}
	var loc *time.Location
	if tag == TagUTC {
		loc = time.UTC
	} else if tag == TagSemicolon {
		loc = time.Local
	} else {
		return timeZero, unexpectedTag(tag, []byte{TagUTC, TagSemicolon})
	}
	d := time.Date(year, time.Month(month), day, hour, min, sec, nsec, loc)
	r.setRef(d)
	return d, nil
}

func (r *simpleReader) ReadTimeWithoutTag() (time.Time, error) {
	hour, min, sec, nsec, tag, err := r.readTime()
	if err != nil {
		return timeZero, err
	}
	var loc *time.Location
	if tag == TagUTC {
		loc = time.UTC
	} else if tag == TagSemicolon {
		loc = time.Local
	} else {
		return timeZero, unexpectedTag(tag, []byte{TagUTC, TagSemicolon})
	}
	t := time.Date(1, 1, 1, hour, min, sec, nsec, loc)
	r.setRef(t)
	return t, nil
}

func (r *simpleReader) ReadString() (string, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return string([]byte{tag}), nil
		case TagInteger, TagLong, TagDouble:
			return r.readUntil(TagSemicolon)
		case TagNull:
			return "", NilError
		case TagEmpty:
			return "", nil
		case TagTrue:
			return "true", nil
		case TagFalse:
			return "false", nil
		case TagNaN:
			return "NaN", nil
		case TagInfinity:
			if sign, err := s.ReadByte(); err == nil {
				return string([]byte{sign}) + "Inf", nil
			}
			return "Inf", err
		case TagDate:
			d, err := r.ReadDateWithoutTag()
			return d.String(), err
		case TagTime:
			t, err := r.ReadTimeWithoutTag()
			return t.String(), err
		case TagUTF8Char:
			return r.readUTF8String(1)
		case TagString:
			return r.ReadStringWithoutTag()
		case TagGuid:
			u, err := r.ReadUUIDWithoutTag()
			return u.String(), err
		case TagBytes:
			if b, err := r.ReadBytesWithoutTag(); err == nil {
				if !utf8.Valid(*b) {
					err = badEncodeError
				}
				return string(*b), err
			}
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(string); ok {
					return ref, nil
				}
				return "", errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type string")
			}
		default:
			return "", convertError(tag, "string")
		}
	}
	return "", err
}

func (r *simpleReader) ReadStringWithoutTag() (str string, err error) {
	if str, err = r.readStringWithoutTag(); err == nil {
		r.setRef(str)
	}
	return str, err
}

func (r *simpleReader) ReadBytes() (*[]byte, error) {
	bytes := new([]byte)
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case TagNull:
			return bytes, NilError
		case TagEmpty:
			return bytes, nil
		case TagUTF8Char:
			c, err := r.readUTF8String(1)
			b := []byte(c)
			return &b, err
		case TagString:
			str, err := r.ReadStringWithoutTag()
			b := []byte(str)
			return &b, err
		case TagGuid:
			u, err := r.ReadUUIDWithoutTag()
			b := []byte(*u)
			return &b, err
		case TagBytes:
			return r.ReadBytesWithoutTag()
		case TagList:
			err = r.ReadSliceWithoutTag(&bytes)
			return bytes, err
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(*[]byte); ok {
					return ref, nil
				}
				return bytes, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type bytes")
			}
		default:
			return bytes, convertError(tag, "bytes")
		}
	}
	return bytes, err
}

func (r *simpleReader) ReadBytesWithoutTag() (*[]byte, error) {
	s := r.stream
	if length, err := r.readInt64(TagQuote); err == nil {
		b := make([]byte, length)
		if _, err = s.Read(b); err == nil {
			err = r.CheckTag(TagQuote)
		}
		r.setRef(&b)
		return &b, err
	} else {
		return new([]byte), err
	}
}

func (r *simpleReader) ReadUUID() (*uuid.UUID, error) {
	id := new(uuid.UUID)
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case TagNull:
			return id, NilError
		case TagString:
			str, err := r.ReadStringWithoutTag()
			u := uuid.Parse(str)
			return &u, err
		case TagGuid:
			return r.ReadUUIDWithoutTag()
		case TagBytes:
			if b, err := r.ReadBytesWithoutTag(); err == nil {
				if len(*b) == 16 {
					u := uuid.UUID(*b)
					return &u, nil
				}
				return id, convertError(TagBytes, "UUID")
			}
			return id, err
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(*uuid.UUID); ok {
					return ref, nil
				}
				return id, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type UUID")
			}
		default:
			return id, convertError(tag, "UUID")
		}
	}
	return id, err
}

func (r *simpleReader) ReadUUIDWithoutTag() (*uuid.UUID, error) {
	s := r.stream
	err := r.CheckTag(TagOpenbrace)
	if err == nil {
		b := make([]byte, 36)
		if _, err = s.Read(b); err == nil {
			err = r.CheckTag(TagClosebrace)
			u := uuid.Parse(string(b))
			r.setRef(&u)
			return &u, err
		}
	}
	return new(uuid.UUID), err
}

func (r *simpleReader) ReadList() (*list.List, error) {
	l := list.New()
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case TagNull:
			return l, NilError
		case TagList:
			return r.ReadListWithoutTag()
		case TagRef:
			var ref interface{}
			if ref, err = r.readRef(); err == nil {
				if ref, ok := ref.(*list.List); ok {
					return ref, nil
				}
				return l, errors.New("cannot convert type " +
					reflect.TypeOf(ref).String() + " to type List")
			}
		default:
			return l, convertError(tag, "List")
		}
	}
	return l, err
}

func (r *simpleReader) ReadListWithoutTag() (*list.List, error) {
	l := list.New()
	length, err := r.readInt64(TagOpenbrace)
	if err == nil {
		for i := 0; i < int(length); i++ {
			if e, err := r.readInterface(); err == nil {
				l.PushBack(e)
			} else {
				return l, err
			}
		}
		if err = r.CheckTag(TagClosebrace); err == nil {
			r.setRef(l)
			return l, nil
		}
	}
	return l, err
}

func (r *simpleReader) ReadSlice(p interface{}) error {
	v, err := r.checkPointer(p)
	if err == nil {
		return r.readSlice(v.Elem())
	}
	return err
}

func (r *simpleReader) ReadSliceWithoutTag(p interface{}) error {
	v, err := r.checkPointer(p)
	if err == nil {
		return r.readSliceWithoutTag(v.Elem())
	}
	return err
}

func (r *simpleReader) ReadMap(p interface{}) error {
	v, err := r.checkPointer(p)
	if err == nil {
		return r.readMap(v.Elem())
	}
	return err
}

func (r *simpleReader) ReadMapWithoutTag(p interface{}) error {
	v, err := r.checkPointer(p)
	if err == nil {
		return r.readMapWithoutTag(v.Elem())
	}
	return err
}

func (r *simpleReader) ReadObject(p interface{}) error {
	v, err := r.checkPointer(p)
	if err == nil {
		return r.readObject(v.Elem())
	}
	return err
}

func (r *simpleReader) ReadObjectWithoutTag(p interface{}) error {
	v, err := r.checkPointer(p)
	if err == nil {
		return r.readObjectWithoutTag(v.Elem())
	}
	return err
}

func (r *simpleReader) Reset() {
	r.classref = r.classref[:0]
	r.fieldsref = r.fieldsref[:0]
}

// private methods

func (r *simpleReader) checkPointer(p interface{}) (v reflect.Value, err error) {
	v = reflect.ValueOf(p)
	if v.Kind() != reflect.Ptr {
		return v, errors.New("argument p must be a pointer")
	}
	return v, nil
}

func (r *simpleReader) unserialize(v reflect.Value) error {
	t := v.Type()
	switch t.Kind() {
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		return r.readInt(v)
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		return r.readUint(v)
	case reflect.Bool:
		return r.readBool(v)
	case reflect.Float32:
		return r.readFloat32(v)
	case reflect.Float64:
		return r.readFloat64(v)
	case reflect.String:
		return r.readString(v)
	case reflect.Slice:
		if t.Name() == "UUID" {
			return r.readUUID(v)
		}
		if t.Elem().Kind() == reflect.Uint8 {
			return r.readBytes(v)
		}
		return r.readSlice(v)
	case reflect.Map:
		return r.readMap(v)
	case reflect.Struct:
		switch t.Name() {
		case "Time":
			return r.readDateTime(v)
		case "Int":
			return r.readBigInt(v)
		case "List":
			return r.readList(v)
		}
		return r.readObject(v)
	case reflect.Ptr:
		switch t := t.Elem(); t.Kind() {
		case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
			return r.readIntPointer(v)
		case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
			return r.readUintPointer(v)
		case reflect.Bool:
			return r.readBoolPointer(v)
		case reflect.Float32:
			return r.readFloat32Pointer(v)
		case reflect.Float64:
			return r.readFloat64Pointer(v)
		case reflect.String:
			return r.readStringPointer(v)
		case reflect.Slice:
			if t.Name() == "UUID" {
				return r.readUUIDPointer(v)
			}
			if t.Elem().Kind() == reflect.Uint8 {
				return r.readBytesPointer(v)
			}
			return r.readSlice(v)
		case reflect.Map:
			return r.readMap(v)
		case reflect.Struct:
			switch t.Name() {
			case "Time":
				return r.readDateTimePointer(v)
			case "Int":
				return r.readBigIntPointer(v)
			case "List":
				return r.readListPointer(v)
			}
			return r.readObject(v)
		case reflect.Interface:
			p, err := r.readInterface()
			if err == nil {
				v.Set(reflect.ValueOf(&p))
			}
			return err
		}
	case reflect.Interface:
		p, err := r.readInterface()
		if err == nil {
			v.Set(reflect.ValueOf(&p).Elem())
		}
		return err
	}
	return errors.New("unsupported Type:" + t.String())
}

func (r *simpleReader) readInterface() (interface{}, error) {
	s := r.stream
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return int(tag - '0'), nil
		case TagInteger:
			i, err := r.ReadIntWithoutTag()
			return int(i), err
		case TagLong:
			return r.ReadBigIntWithoutTag()
		case TagDouble:
			return r.ReadFloat64WithoutTag()
		case TagNull:
			return nil, nil
		case TagEmpty:
			return "", nil
		case TagTrue:
			return true, nil
		case TagFalse:
			return false, nil
		case TagNaN:
			return math.NaN(), nil
		case TagInfinity:
			return r.readInfinity()
		case TagDate:
			return r.ReadDateWithoutTag()
		case TagTime:
			return r.ReadTimeWithoutTag()
		case TagBytes:
			return r.ReadBytesWithoutTag()
		case TagUTF8Char:
			return r.readUTF8String(1)
		case TagString:
			return r.ReadStringWithoutTag()
		case TagGuid:
			return r.ReadUUIDWithoutTag()
		case TagList:
			var e *[]interface{}
			err := r.ReadSliceWithoutTag(&e)
			return e, err
		case TagMap:
			var e *map[interface{}]interface{}
			err := r.ReadMapWithoutTag(&e)
			return e, err
		case TagClass:
			err := r.readClass()
			if err == nil {
				var e interface{}
				err := r.ReadObject(&e)
				return e, err
			}
			return nil, err
		case TagObject:
			var e interface{}
			err := r.ReadObjectWithoutTag(&e)
			return e, err
		case TagRef:
			return r.readRef()
		}
		return nil, unexpectedTag(tag, nil)
	}
	return nil, err
}

func (r *simpleReader) readUntil(tag byte) (string, error) {
	if buf, err := r.stream.ReadBytes(tag); err == nil {
		return string(buf[:len(buf)-1]), nil
	} else {
		return string(buf), err
	}
}

func (r *simpleReader) skipUntil(tag byte) error {
	_, err := r.stream.ReadBytes(tag)
	return err
}

func (r *simpleReader) readInt64(tag byte) (int64, error) {
	s := r.stream
	i := int64(0)
	b, err := s.ReadByte()
	if err == nil && b == tag {
		return i, nil
	}
	if err != nil {
		return i, err
	}
	sign := int64(1)
	switch b {
	case '-':
		sign = -1
		fallthrough
	case '+':
		b, err = s.ReadByte()
	}
	for b != tag && err == nil {
		i *= 10
		i += int64(b-'0') * sign
		b, err = s.ReadByte()
	}
	return i, err
}

func (r *simpleReader) readUint64(tag byte) (uint64, error) {
	i, err := r.readInt64(tag)
	return uint64(i), err
}

func (r *simpleReader) readIntAsFloat64(tag byte) (float64, error) {
	s := r.stream
	f := float64(0)
	b, err := s.ReadByte()
	if err == nil && b == tag {
		return f, nil
	}
	if err != nil {
		return f, err
	}
	sign := float64(1)
	switch b {
	case '-':
		sign = -1
		fallthrough
	case '+':
		b, err = s.ReadByte()
	}
	for b != tag && err == nil {
		f *= 10
		f += float64(b-'0') * sign
		b, err = s.ReadByte()
	}
	return f, err
}

func (r *simpleReader) readIntAsFloat32(tag byte) (float32, error) {
	f, err := r.readIntAsFloat64(tag)
	return float32(f), err
}

func (r *simpleReader) readInfinity() (float64, error) {
	if sign, err := r.stream.ReadByte(); err == nil {
		switch sign {
		case '+':
			return math.Inf(1), nil
		case '-':
			return math.Inf(-1), nil
		default:
			return math.NaN(), unexpectedTag(sign, []byte{'+', '-'})
		}
	} else {
		return math.NaN(), err
	}
}

func (r *simpleReader) readTime() (hour int, min int, sec int, nsec int, tag byte, err error) {
	s := r.stream
	if tag, err = s.ReadByte(); err == nil {
		hour = int(tag - '0')
		if tag, err = s.ReadByte(); err == nil {
			hour *= 10
			hour += int(tag - '0')
			if tag, err = s.ReadByte(); err == nil {
				min = int(tag - '0')
				if tag, err = s.ReadByte(); err == nil {
					min *= 10
					min += int(tag - '0')
					if tag, err = s.ReadByte(); err == nil {
						sec = int(tag - '0')
						if tag, err = s.ReadByte(); err == nil {
							sec *= 10
							sec += int(tag - '0')
							tag, err = s.ReadByte()
						}
					}
				}
			}
		}
	}
	if err != nil {
		return hour, min, sec, nsec, tag, err
	}
	if tag == TagPoint {
		if tag, err = s.ReadByte(); err == nil {
			nsec = int(tag - '0')
			if tag, err = s.ReadByte(); err == nil {
				nsec *= 10
				nsec += int(tag - '0')
				if tag, err = s.ReadByte(); err == nil {
					nsec *= 10
					nsec += int(tag - '0')
					tag, err = s.ReadByte()
				}
			}
		}
		if err != nil {
			return hour, min, sec, nsec, tag, err
		}
		if tag >= '0' && tag <= '9' {
			nsec *= 10
			nsec += int(tag - '0')
			if tag, err = s.ReadByte(); err == nil {
				nsec *= 10
				nsec += int(tag - '0')
				if tag, err = s.ReadByte(); err == nil {
					nsec *= 10
					nsec += int(tag - '0')
					tag, err = s.ReadByte()
				}
			}
		} else {
			nsec *= 1000
		}
		if err != nil {
			return hour, min, sec, nsec, tag, err
		}
		if tag >= '0' && tag <= '9' {
			nsec *= 10
			nsec += int(tag - '0')
			if tag, err = s.ReadByte(); err == nil {
				nsec *= 10
				nsec += int(tag - '0')
				if tag, err = s.ReadByte(); err == nil {
					nsec *= 10
					nsec += int(tag - '0')
					tag, err = s.ReadByte()
				}
			}
		} else {
			nsec *= 1000
		}
	}
	return hour, min, sec, nsec, tag, err
}

func (r *simpleReader) readStringWithoutTag() (str string, err error) {
	var length int64
	if length, err = r.readInt64(TagQuote); err == nil {
		if str, err = r.readUTF8String(int(length)); err == nil {
			err = r.CheckTag(TagQuote)
		}
	}
	return str, err
}

func (r *simpleReader) readInt(v reflect.Value) error {
	if x, err := r.ReadInt(); err == nil || err == NilError {
		v.SetInt(x)
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readUint(v reflect.Value) error {
	if x, err := r.ReadUint(); err == nil || err == NilError {
		v.SetUint(x)
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readBool(v reflect.Value) error {
	if x, err := r.ReadBool(); err == nil || err == NilError {
		v.SetBool(x)
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readFloat32(v reflect.Value) error {
	if x, err := r.ReadFloat32(); err == nil || err == NilError {
		v.SetFloat(float64(x))
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readFloat64(v reflect.Value) error {
	if x, err := r.ReadFloat64(); err == nil || err == NilError {
		v.SetFloat(x)
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readBigInt(v reflect.Value) error {
	if x, err := r.ReadBigInt(); err == nil || err == NilError {
		v.Set(reflect.ValueOf(*x))
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readDateTime(v reflect.Value) error {
	if x, err := r.ReadDateTime(); err == nil || err == NilError {
		v.Set(reflect.ValueOf(x))
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readString(v reflect.Value) error {
	if x, err := r.ReadString(); err == nil || err == NilError {
		v.SetString(x)
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readBytes(v reflect.Value) error {
	if x, err := r.ReadBytes(); err == nil || err == NilError {
		v.Set(reflect.ValueOf(*x))
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readUUID(v reflect.Value) error {
	if x, err := r.ReadUUID(); err == nil || err == NilError {
		v.Set(reflect.ValueOf(*x))
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readList(v reflect.Value) error {
	if x, err := r.ReadList(); err == nil || err == NilError {
		v.Set(reflect.ValueOf(*x))
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) getRefWithType(v reflect.Value, kind reflect.Kind) error {
	t := v.Type()
	if ref, err := r.readRef(); err == nil {
		refValue := reflect.ValueOf(ref)
		refType := refValue.Type()
		if refType.Kind() == reflect.Ptr && refType.Elem().Kind() == kind {
			if refType.AssignableTo(t) {
				v.Set(refValue)
			} else if refType.Elem().AssignableTo(t) {
				v.Set(refValue.Elem())
			}
		}
		return errors.New("cannot convert type " +
			refType.String() + " to type " + t.String())
	} else {
		return err
	}
}

func (r *simpleReader) readSlice(v reflect.Value) error {
	s := r.Stream()
	t := v.Type()
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case TagNull:
			v.Set(reflect.Zero(t))
			return nil
		case TagList:
			return r.readSliceWithoutTag(v)
		case TagRef:
			return r.getRefWithType(v, reflect.Slice)

		}
		return convertError(tag, v.Type().String())
	}
	return err
}

func (r *simpleReader) readSliceWithoutTag(v reflect.Value) error {
	t := v.Type()
	switch t.Kind() {
	case reflect.Slice:
	case reflect.Interface:
		t = reflect.TypeOf([]interface{}(nil))
	case reflect.Ptr:
		switch t = t.Elem(); t.Kind() {
		case reflect.Slice:
		case reflect.Interface:
			t = reflect.TypeOf([]interface{}(nil))
		default:
			return errors.New("cannot convert slice to type " + t.String())
		}
	default:
		return errors.New("cannot convert slice to type " + t.String())
	}
	slicePointer := reflect.New(t)
	slice := slicePointer.Elem()
	length, err := r.readInt64(TagOpenbrace)
	if err == nil {
		length := int(length)
		slice.Set(reflect.MakeSlice(t, length, length))
		for i := 0; i < int(length); i++ {
			elem := slice.Index(i)
			if err := r.unserialize(elem); err != nil {
				return err
			}
		}
		if err = r.CheckTag(TagClosebrace); err == nil {
			r.setRef(slicePointer.Interface())
			switch t := v.Type(); t.Kind() {
			case reflect.Slice:
				v.Set(slice)
			case reflect.Interface:
				v.Set(slicePointer)
			case reflect.Ptr:
				switch t.Elem().Kind() {
				case reflect.Slice:
					v.Set(slicePointer)
				case reflect.Interface:
					v.Set(reflect.New(t.Elem()))
					v.Elem().Set(slicePointer)
				}
			}
			return nil
		}
	}
	return err
}

func (r *simpleReader) readMap(v reflect.Value) error {
	s := r.Stream()
	t := v.Type()
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case TagNull:
			v.Set(reflect.Zero(t))
			return nil
		case TagMap:
			return r.readMapWithoutTag(v)
		case TagRef:
			return r.getRefWithType(v, reflect.Map)

		}
		return convertError(tag, v.Type().String())
	}
	return err
}

func (r *simpleReader) readMapWithoutTag(v reflect.Value) error {
	t := v.Type()
	switch t.Kind() {
	case reflect.Map:
	case reflect.Interface:
		t = reflect.TypeOf(map[interface{}]interface{}(nil))
	case reflect.Ptr:
		switch t = t.Elem(); t.Kind() {
		case reflect.Map:
		case reflect.Interface:
			t = reflect.TypeOf(map[interface{}]interface{}(nil))
		default:
			return errors.New("cannot convert map to type " + t.String())
		}
	default:
		return errors.New("cannot convert map to type " + t.String())
	}
	mPointer := reflect.New(t)
	m := mPointer.Elem()
	length, err := r.readInt64(TagOpenbrace)
	if err == nil {
		length := int(length)
		m.Set(reflect.MakeMap(t))
		for i := 0; i < int(length); i++ {
			key := reflect.New(t.Key()).Elem()
			val := reflect.New(t.Elem()).Elem()
			if err := r.unserialize(key); err != nil {
				return err
			}
			if err := r.unserialize(val); err != nil {
				return err
			}
			m.SetMapIndex(key, val)
		}
		if err = r.CheckTag(TagClosebrace); err == nil {
			r.setRef(mPointer.Interface())
			switch t := v.Type(); t.Kind() {
			case reflect.Map:
				v.Set(m)
			case reflect.Interface:
				v.Set(mPointer)
			case reflect.Ptr:
				switch t.Elem().Kind() {
				case reflect.Map:
					v.Set(mPointer)
				case reflect.Interface:
					v.Set(reflect.New(t.Elem()))
					v.Elem().Set(mPointer)
				}
			}
			return nil
		}
	}
	return err
}

func (r *simpleReader) checkRegister(t reflect.Type) {
	if t.Kind() == reflect.Ptr {
		t = t.Elem()
	}
	if t.Kind() == reflect.Struct {
		alias := ClassManager.GetClassAlias(t)
		if alias == "" {
			class := ClassManager.GetClass(t.Name())
			if class == nil {
				ClassManager.Register(t, t.Name())
			}
		}
	}
}

func (r *simpleReader) readObject(v reflect.Value) error {
	s := r.Stream()
	t := v.Type()
	r.checkRegister(t)
	tag, err := s.ReadByte()
	if err == nil {
		switch tag {
		case TagNull:
			v.Set(reflect.Zero(t))
			return nil
		case TagClass:
			if err = r.readClass(); err == nil {
				return r.readObject(v)
			} else {
				return err
			}
		case TagObject:
			return r.readObjectWithoutTag(v)
		case TagRef:
			return r.getRefWithType(v, reflect.Struct)
		}
		return convertError(tag, v.Type().String())
	}
	return err
}

func (r *simpleReader) readObjectWithoutTag(v reflect.Value) error {
	index, err := r.readInt64(TagOpenbrace)
	class := r.classref[int(index)]
	t := v.Type()
	assignable := class.AssignableTo(t)
	if t.Kind() == reflect.Ptr {
		assignable = class.AssignableTo(t.Elem())
	}
	if !assignable {
		return errors.New("cannot convert type " + class.String() + " to type " + t.String())
	}
	objPointer := reflect.New(class)
	r.setRef(objPointer.Interface())
	obj := objPointer.Elem()
	fileds := r.fieldsref[int(index)]
	count := len(fileds)
	for i := 0; i < count; i++ {
		field := obj.FieldByNameFunc(func(name string) bool {
			return strings.EqualFold(fileds[i], name)
		})
		if field.IsValid() {
			err = r.unserialize(field)
		} else {
			_, err = r.readInterface()
		}
		if err != nil {
			return err
		}
	}
	if err = r.CheckTag(TagClosebrace); err == nil {
		switch t := v.Type(); t.Kind() {
		case reflect.Struct:
			v.Set(obj)
		case reflect.Interface:
			v.Set(objPointer)
		case reflect.Ptr:
			switch t.Elem().Kind() {
			case reflect.Struct:
				v.Set(objPointer)
			case reflect.Interface:
				v.Set(reflect.New(t.Elem()))
				v.Elem().Set(objPointer)
			}
		}
		return nil
	}
	return err
}

func (r *simpleReader) readClass() error {
	className, err := r.readStringWithoutTag()
	if err != nil {
		return err
	}
	class := ClassManager.GetClass(className)
	if class == nil {
		return errors.New("type " + className + " was not registered in ClassManager")
	}
	count, err := r.readInt64(TagOpenbrace)
	if err != nil {
		return err
	}
	length := int(count)
	fields := make([]string, length, length)
	for i := 0; i < length; i++ {
		if fields[i], err = r.ReadString(); err != nil {
			return err
		}
	}
	if err = r.CheckTag(TagClosebrace); err != nil {
		return err
	}
	r.classref = append(r.classref, class)
	r.fieldsref = append(r.fieldsref, fields)
	return nil
}

func (r *simpleReader) readPointer(v reflect.Value, readValue func() (interface{}, error), setValue func(reflect.Value, interface{})) error {
	if x, err := readValue(); err == nil {
		if reflect.TypeOf(x).Kind() != reflect.Ptr {
			v.Set(reflect.New(v.Type().Elem()))
			setValue(v.Elem(), x)
		} else {
			setValue(v, x)
		}
		return nil
	} else if err == NilError {
		v.Set(reflect.Zero(v.Type()))
		return nil
	} else {
		return err
	}
}

func (r *simpleReader) readIntPointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadInt() },
		func(v reflect.Value, x interface{}) { v.SetInt(x.(int64)) })
}

func (r *simpleReader) readUintPointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadUint() },
		func(v reflect.Value, x interface{}) { v.SetUint(x.(uint64)) })
}

func (r *simpleReader) readBoolPointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadBool() },
		func(v reflect.Value, x interface{}) { v.SetBool(x.(bool)) })
}

func (r *simpleReader) readFloat32Pointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadFloat32() },
		func(v reflect.Value, x interface{}) { v.SetFloat(float64(x.(float32))) })
}

func (r *simpleReader) readFloat64Pointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadFloat64() },
		func(v reflect.Value, x interface{}) { v.SetFloat(x.(float64)) })
}

func (r *simpleReader) readBigIntPointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadBigInt() },
		func(v reflect.Value, x interface{}) { v.Set(reflect.ValueOf(x)) })
}

func (r *simpleReader) readDateTimePointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadDateTime() },
		func(v reflect.Value, x interface{}) { v.Set(reflect.ValueOf(x)) })
}

func (r *simpleReader) readStringPointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadString() },
		func(v reflect.Value, x interface{}) { v.SetString(x.(string)) })
}

func (r *simpleReader) readBytesPointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadBytes() },
		func(v reflect.Value, x interface{}) { v.Set(reflect.ValueOf(x)) })
}

func (r *simpleReader) readUUIDPointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadUUID() },
		func(v reflect.Value, x interface{}) { v.Set(reflect.ValueOf(x)) })
}

func (r *simpleReader) readListPointer(v reflect.Value) error {
	return r.readPointer(v,
		func() (interface{}, error) { return r.ReadList() },
		func(v reflect.Value, x interface{}) { v.Set(reflect.ValueOf(x)) })
}

// private functions

func convertError(tag byte, dst string) error {
	if src, err := tagToString(tag); err == nil {
		return errors.New("cannot convert type " + src + " to type " + dst)
	} else {
		return err
	}
}

func tagToString(tag byte) (string, error) {
	switch tag {
	case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', TagInteger:
		return "int", nil
	case TagLong:
		return "big.Int", nil
	case TagDouble:
		return "float64", nil
	case TagNull:
		return "nil", nil
	case TagEmpty:
		return "empty string", nil
	case TagTrue:
		return "bool true", nil
	case TagFalse:
		return "bool false", nil
	case TagNaN:
		return "NaN", nil
	case TagInfinity:
		return "Infinity", nil
	case TagDate:
		return "time.Time", nil
	case TagTime:
		return "time.Time", nil
	case TagBytes:
		return "[]byte", nil
	case TagUTF8Char:
		return "string", nil
	case TagString:
		return "string", nil
	case TagGuid:
		return "uuid.UUID", nil
	case TagList:
		return "slice", nil
	case TagMap:
		return "map", nil
	case TagClass:
		return "struct type", nil
	case TagObject:
		return "struct value", nil
	case TagRef:
		return "value reference", nil
	case TagError:
		return "error", nil
	default:
		return "unknown", unexpectedTag(tag, nil)
	}
}

func stringToBigInt(str string) (*big.Int, error) {
	if bigint, success := new(big.Int).SetString(str, 0); success {
		return bigint, nil
	}
	return big.NewInt(0), errors.New(`cannot convert string "` + str + `" to type big.Int`)
}
