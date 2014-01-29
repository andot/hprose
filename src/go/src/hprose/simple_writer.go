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
 * hprose/simple_writer.go                                *
 *                                                        *
 * hprose SimpleWriter for Go.                            *
 *                                                        *
 * LastModified: Jan 30, 2014                             *
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
	"time"
	"unicode/utf8"
	"uuid"
)

const rune3Max = 1<<16 - 1

var serializeType = [...]bool{
	false, // Invalid
	true,  // Bool
	true,  // Int
	true,  // Int8
	true,  // Int16
	true,  // Int32
	true,  // Int64
	true,  // Uint
	true,  // Uint8
	true,  // Uint16
	true,  // Uint32
	true,  // Uint64
	false, // Uintptr
	true,  // Float32
	true,  // Float64
	false, // Complex64
	false, // Complex128
	true,  // Array
	false, // Chan
	false, // Func
	true,  // Interface
	true,  // Map
	true,  // Ptr
	true,  // Slice
	true,  // String
	true,  // Struct
	false, // UnsafePointer
}

type simpleWriter struct {
	stream    *bufio.Writer
	classref  map[string]int
	fieldsref [][]reflect.StructField
	setRef    func(interface{})
	writeRef  func(interface{}) (bool, error)
}

func NewSimpleWriter(stream io.Writer) Writer {
	w := &simpleWriter{}
	w.stream = bufio.NewWriter(stream)
	w.classref = make(map[string]int, 16)
	w.fieldsref = make([][]reflect.StructField, 0, 16)
	w.setRef = func(interface{}) {}
	w.writeRef = func(interface{}) (bool, error) {
		return false, nil
	}
	return w
}

func (w *simpleWriter) Stream() *bufio.Writer {
	return w.stream
}

func (w *simpleWriter) Serialize(v interface{}) (err error) {
	switch v := v.(type) {
	case nil:
		err = w.WriteNull()
	case int:
		err = w.WriteInt(v)
	case uint:
		err = w.WriteUint(v)
	case int8:
		err = w.WriteInt8(v)
	case uint8:
		err = w.WriteUint8(v)
	case int16:
		err = w.WriteInt16(v)
	case uint16:
		err = w.WriteUint16(v)
	case int32:
		err = w.WriteInt32(v)
	case uint32:
		err = w.WriteUint32(v)
	case int64:
		err = w.WriteInt64(v)
	case uint64:
		err = w.WriteUint64(v)
	case *int:
		err = w.WriteInt(*v)
	case *uint:
		err = w.WriteUint(*v)
	case *int8:
		err = w.WriteInt8(*v)
	case *uint8:
		err = w.WriteUint8(*v)
	case *int16:
		err = w.WriteInt16(*v)
	case *uint16:
		err = w.WriteUint16(*v)
	case *int32:
		err = w.WriteInt32(*v)
	case *uint32:
		err = w.WriteUint32(*v)
	case *int64:
		err = w.WriteInt64(*v)
	case *uint64:
		err = w.WriteUint64(*v)
	case big.Int:
		err = w.WriteBigInt(&v)
	case *big.Int:
		err = w.WriteBigInt(v)
	case float32:
		err = w.WriteFloat32(v)
	case float64:
		err = w.WriteFloat64(v)
	case *float32:
		err = w.WriteFloat32(*v)
	case *float64:
		err = w.WriteFloat64(*v)
	case bool:
		err = w.WriteBool(v)
	case *bool:
		err = w.WriteBool(*v)
	case time.Time:
		err = w.WriteTimeWithRef(v)
	case *time.Time:
		err = w.WriteTimeWithRef(*v)
	case string:
		if length := len(v); length == 0 {
			err = w.WriteEmpty()
		} else if length < utf8.UTFMax && utf8.RuneCountInString(v) == 1 {
			err = w.WriteUTF8Char(v)
		} else {
			err = w.WriteStringWithRef(v)
		}
	case *string:
		err = w.WriteStringWithRef(*v)
	case []byte:
		if len(v) == 0 {
			err = w.WriteEmpty()
		} else {
			err = w.WriteBytesWithRef(&v)
		}
	case *[]byte:
		err = w.WriteBytesWithRef(v)
	case uuid.UUID:
		err = w.WriteUUIDWithRef(&v)
	case *uuid.UUID:
		err = w.WriteUUIDWithRef(v)
	case list.List:
		err = w.WriteListWithRef(&v)
	case *list.List:
		err = w.WriteListWithRef(v)
	case *interface{}:
		switch x := (*v).(type) {
		case nil:
			err = w.WriteNull()
		case int:
			err = w.WriteInt(x)
		case uint:
			err = w.WriteUint(x)
		case int8:
			err = w.WriteInt8(x)
		case uint8:
			err = w.WriteUint8(x)
		case int16:
			err = w.WriteInt16(x)
		case uint16:
			err = w.WriteUint16(x)
		case int32:
			err = w.WriteInt32(x)
		case uint32:
			err = w.WriteUint32(x)
		case int64:
			err = w.WriteInt64(x)
		case uint64:
			err = w.WriteUint64(x)
		case big.Int:
			err = w.WriteBigInt(&x)
		case float32:
			err = w.WriteFloat32(x)
		case float64:
			err = w.WriteFloat64(x)
		case bool:
			err = w.WriteBool(x)
		case time.Time:
			err = w.WriteTimeWithRef(x)
		case string:
			err = w.WriteStringWithRef(x)
		case []byte:
			err = w.WriteBytesWithRef(&x)
		case uuid.UUID:
			err = w.WriteUUIDWithRef(&x)
		case list.List:
			err = w.WriteListWithRef(&x)
		default:
			err = w.writeComplexData(v)
		}
	default:
		err = w.writeComplexData(v)
	}
	if err == nil {
		err = w.stream.Flush()
	}
	return err
}

func (w *simpleWriter) WriteNull() error {
	return w.stream.WriteByte(TagNull)
}

func (w *simpleWriter) WriteInt8(v int8) error {
	return w.writeInt32(int32(v))
}

func (w *simpleWriter) WriteInt16(v int16) error {
	return w.writeInt32(int32(v))
}

func (w *simpleWriter) WriteInt32(v int32) error {
	return w.writeInt32(v)
}

func (w *simpleWriter) WriteInt64(v int64) error {
	if v >= math.MinInt32 && v <= math.MaxInt32 {
		return w.writeInt32(int32(v))
	}
	return w.writeInt64(v)
}

func (w *simpleWriter) WriteUint8(v uint8) error {
	return w.writeInt32(int32(v))
}

func (w *simpleWriter) WriteUint16(v uint16) error {
	return w.writeInt32(int32(v))
}

func (w *simpleWriter) WriteUint32(v uint32) error {
	if v <= math.MaxInt32 {
		return w.writeInt32(int32(v))
	}
	return w.writeUint64(uint64(v))
}

func (w *simpleWriter) WriteUint64(v uint64) error {
	if v <= math.MaxInt32 {
		return w.writeInt32(int32(v))
	}
	return w.writeUint64(v)
}

func (w *simpleWriter) WriteInt(v int) error {
	if v >= math.MinInt32 && v <= math.MaxInt32 {
		return w.writeInt32(int32(v))
	}
	return w.writeInt64(int64(v))
}

func (w *simpleWriter) WriteUint(v uint) error {
	if v <= math.MaxInt32 {
		return w.writeInt32(int32(v))
	}
	return w.writeUint64(uint64(v))
}

func (w *simpleWriter) WriteBigInt(v *big.Int) (err error) {
	s := w.stream
	if err = s.WriteByte(TagLong); err == nil {
		if _, err = s.WriteString(v.String()); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *simpleWriter) WriteFloat32(v float32) error {
	return w.WriteFloat64(float64(v))
}

func (w *simpleWriter) WriteFloat64(v float64) (err error) {
	s := w.stream
	if math.IsNaN(v) {
		return w.WriteNaN()
	} else if math.IsInf(v, 0) {
		return w.WriteInfinity(v > 0)
	} else if err = s.WriteByte(TagDouble); err == nil {
		if _, err = s.WriteString(strconv.FormatFloat(v, 'g', -1, 64)); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *simpleWriter) WriteNaN() error {
	return w.stream.WriteByte(TagNaN)
}

func (w *simpleWriter) WriteInfinity(pos bool) (err error) {
	s := w.Stream()
	if err = s.WriteByte(TagInfinity); err == nil {
		if pos {
			err = s.WriteByte(TagPos)
		} else {
			err = s.WriteByte(TagNeg)
		}
	}
	return err
}

func (w *simpleWriter) WriteBool(v bool) error {
	s := w.stream
	if v {
		return s.WriteByte(TagTrue)
	}
	return s.WriteByte(TagFalse)
}

func (w *simpleWriter) WriteTime(v time.Time) (err error) {
	w.setRef(v)
	s := w.stream
	year, month, day := v.Date()
	hour, min, sec := v.Clock()
	nsec := v.Nanosecond()
	tag := TagSemicolon
	if v.Location() == time.UTC {
		tag = TagUTC
	}
	if hour == 0 && min == 0 && sec == 0 && nsec == 0 {
		if _, err = s.Write(formatDate(year, int(month), day)); err == nil {
			err = s.WriteByte(tag)
		}
	} else if year == 1 && month == 1 && day == 1 {
		if _, err = s.Write(formatTime(hour, min, sec, nsec)); err == nil {
			err = s.WriteByte(tag)
		}
	} else if _, err = s.Write(formatDate(year, int(month), day)); err == nil {
		if _, err = s.Write(formatTime(hour, min, sec, nsec)); err == nil {
			err = s.WriteByte(tag)
		}
	}
	return err
}

func (w *simpleWriter) WriteTimeWithRef(v time.Time) error {
	if success, err := w.writeRef(v); err == nil && !success {
		return w.WriteTime(v)
	} else {
		return err
	}
}

func (w *simpleWriter) WriteEmpty() error {
	return w.stream.WriteByte(TagEmpty)
}

func (w *simpleWriter) WriteUTF8Char(v string) (err error) {
	s := w.stream
	if err = s.WriteByte(TagUTF8Char); err == nil {
		_, err = s.WriteString(v)
	}
	return err
}

func (w *simpleWriter) WriteString(v string) (err error) {
	w.setRef(v)
	s := w.stream
	if err = s.WriteByte(TagString); err == nil {
		if length := ulen(v); length > 0 {
			if _, err = s.WriteString(strconv.Itoa(length)); err == nil {
				if err = s.WriteByte(TagQuote); err == nil {
					if _, err = s.WriteString(v); err == nil {
						err = s.WriteByte(TagQuote)
					}
				}
			}
		} else if err = s.WriteByte(TagQuote); err == nil {
			err = s.WriteByte(TagQuote)
		}
	}
	return err
}

func (w *simpleWriter) WriteStringWithRef(v string) error {
	if success, err := w.writeRef(v); err == nil && !success {
		return w.WriteString(v)
	} else {
		return err
	}
}

func (w *simpleWriter) WriteBytes(v *[]byte) (err error) {
	w.setRef(v)
	s := w.stream
	if err = s.WriteByte(TagBytes); err == nil {
		if length := len(*v); length > 0 {
			if _, err = s.WriteString(strconv.Itoa(length)); err == nil {
				if err = s.WriteByte(TagQuote); err == nil {
					if _, err = s.Write(*v); err == nil {
						err = s.WriteByte(TagQuote)
					}
				}
			}
		} else if err = s.WriteByte(TagQuote); err == nil {
			err = s.WriteByte(TagQuote)
		}
	}
	return err
}

func (w *simpleWriter) WriteBytesWithRef(v *[]byte) error {
	if success, err := w.writeRef(v); err == nil && !success {
		return w.WriteBytes(v)
	} else {
		return err
	}
}

func (w *simpleWriter) WriteUUID(v *uuid.UUID) (err error) {
	w.setRef(v)
	s := w.stream
	if err = s.WriteByte(TagGuid); err == nil {
		if err = s.WriteByte(TagOpenbrace); err == nil {
			if _, err = s.WriteString(v.String()); err == nil {
				err = s.WriteByte(TagClosebrace)
			}
		}
	}
	return err
}

func (w *simpleWriter) WriteUUIDWithRef(v *uuid.UUID) error {
	if success, err := w.writeRef(v); err == nil && !success {
		return w.WriteUUID(v)
	} else {
		return err
	}
}

func (w *simpleWriter) WriteList(v *list.List) (err error) {
	w.setRef(v)
	s := w.stream
	count := v.Len()
	if err = s.WriteByte(TagList); err == nil {
		if count > 0 {
			if _, err = s.WriteString(strconv.Itoa(count)); err == nil {
				if err = s.WriteByte(TagOpenbrace); err == nil {
					for e := v.Front(); e != nil; e = e.Next() {
						if err = w.Serialize(e.Value); err != nil {
							return err
						}
					}
					err = s.WriteByte(TagClosebrace)
				}
			}
		} else if err = s.WriteByte(TagOpenbrace); err == nil {
			err = s.WriteByte(TagClosebrace)
		}
	}
	return err
}

func (w *simpleWriter) WriteListWithRef(v *list.List) error {
	if success, err := w.writeRef(v); err == nil && !success {
		return w.WriteList(v)
	} else {
		return err
	}
}

func (w *simpleWriter) WriteSlice(v interface{}) error {
	x := v
	if v := reflect.ValueOf(v); v.IsValid() {
		if kind := v.Kind(); kind == reflect.Array || kind == reflect.Slice {
			w.setRef(&x)
			return w.writeSliceValue(v)
		} else if kind == reflect.Ptr {
			if v := v.Elem(); v.IsValid() {
				if kind := v.Kind(); kind == reflect.Array || kind == reflect.Slice {
					w.setRef(x)
					return w.writeSliceValue(v)
				} else if kind == reflect.Interface {
					if v := v.Elem(); v.IsValid() {
						if kind = v.Kind(); kind == reflect.Array || kind == reflect.Slice {
							w.setRef(x)
							return w.writeSliceValue(v)
						}
					}
				}
			}
		}
	}
	return errors.New("The data is not an array/slice or an array/slice pointer.")
}

func (w *simpleWriter) WriteSliceWithRef(v interface{}) error {
	if success, err := w.writeRef(v); err == nil && !success {
		return w.WriteSlice(v)
	} else {
		return err
	}
}

func (w *simpleWriter) WriteMap(v interface{}) error {
	x := v
	if v := reflect.ValueOf(v); v.IsValid() {
		if kind := v.Kind(); kind == reflect.Map {
			w.setRef(&x)
			return w.writeMapValue(v)
		} else if kind == reflect.Ptr {
			if v := v.Elem(); v.IsValid() {
				if kind := v.Kind(); kind == reflect.Map {
					w.setRef(x)
					return w.writeMapValue(v)
				} else if kind == reflect.Interface {
					if v := v.Elem(); v.IsValid() {
						if kind = v.Kind(); kind == reflect.Map {
							w.setRef(x)
							return w.writeMapValue(v)
						}
					}
				}
			}
		}
	}
	return errors.New("The data is not a map or a map pointer.")
}

func (w *simpleWriter) WriteMapWithRef(v interface{}) error {
	if success, err := w.writeRef(v); err == nil && !success {
		return w.WriteMap(v)
	} else {
		return err
	}
}

func (w *simpleWriter) WriteObject(v interface{}) error {
	if rv := reflect.ValueOf(v); rv.IsValid() {
		if kind := rv.Kind(); kind == reflect.Struct {
			return w.writeObjectValue(&v, rv)
		} else if kind == reflect.Ptr {
			if rv := rv.Elem(); rv.IsValid() {
				if kind := rv.Kind(); kind == reflect.Struct {
					return w.writeObjectValue(v, rv)
				} else if kind == reflect.Interface {
					if rv := rv.Elem(); rv.IsValid() {
						if kind = rv.Kind(); kind == reflect.Struct {
							return w.writeObjectValue(v, rv)
						}
					}
				}
			}
		}
	}
	return errors.New("The data is not a struct or a struct pointer.")
}

func (w *simpleWriter) WriteObjectWithRef(v interface{}) error {
	if success, err := w.writeRef(v); err == nil && !success {
		return w.WriteObject(v)
	} else {
		return err
	}
}

func (w *simpleWriter) Reset() {
	w.classref = make(map[string]int, cap(w.fieldsref))
	w.fieldsref = w.fieldsref[:0]
}

// private methods

func (w *simpleWriter) writeInt32(v int32) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else if err = s.WriteByte(TagInteger); err == nil {
		if _, err = s.WriteString(strconv.FormatInt(int64(v), 10)); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *simpleWriter) writeInt64(v int64) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else if err = s.WriteByte(TagLong); err == nil {
		if _, err = s.WriteString(strconv.FormatInt(v, 10)); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *simpleWriter) writeUint64(v uint64) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else if err = s.WriteByte(TagLong); err == nil {
		if _, err = s.WriteString(strconv.FormatUint(v, 10)); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *simpleWriter) writeComplexData(v interface{}) (err error) {
	rv := reflect.ValueOf(v)
	switch rv.Kind() {
	case reflect.Array, reflect.Slice:
		err = w.WriteSliceWithRef(&v)
	case reflect.Map:
		err = w.WriteMapWithRef(&v)
	case reflect.Struct:
		err = w.WriteObjectWithRef(&v)
	case reflect.Ptr:
		switch rv = rv.Elem(); rv.Kind() {
		case reflect.Interface:
			err = w.writeComplexData(rv.Interface())
		case reflect.Array, reflect.Slice:
			err = w.WriteSliceWithRef(v)
		case reflect.Map:
			err = w.WriteMapWithRef(v)
		case reflect.Struct:
			err = w.WriteObjectWithRef(v)
		}
	}
	return err
}

func (w *simpleWriter) writeSliceValue(v reflect.Value) (err error) {
	s := w.Stream()
	count := v.Len()
	if err = s.WriteByte(TagList); err == nil {
		if count > 0 {
			if _, err = s.WriteString(strconv.Itoa(count)); err == nil {
				if err = s.WriteByte(TagOpenbrace); err == nil {
					for i := 0; i < count; i++ {
						if err = w.Serialize(v.Index(i).Interface()); err != nil {
							return err
						}
					}
					err = s.WriteByte(TagClosebrace)
				}
			}
		} else if err = s.WriteByte(TagOpenbrace); err == nil {
			err = s.WriteByte(TagClosebrace)
		}
	}
	return err
}

func (w *simpleWriter) writeMapValue(v reflect.Value) (err error) {
	s := w.Stream()
	count := v.Len()
	if err = s.WriteByte(TagMap); err == nil {
		if count > 0 {
			if _, err = s.WriteString(strconv.Itoa(count)); err == nil {
				if err = s.WriteByte(TagOpenbrace); err == nil {
					keys := v.MapKeys()
					for _, key := range keys {
						if err = w.Serialize(key.Interface()); err != nil {
							return err
						}
						if err = w.Serialize(v.MapIndex(key).Interface()); err != nil {
							return err
						}
					}
					err = s.WriteByte(TagClosebrace)
				}
			}
		} else if err = s.WriteByte(TagOpenbrace); err == nil {
			err = s.WriteByte(TagClosebrace)
		}
	}
	return err
}

func (w *simpleWriter) writeObjectValue(v interface{}, rv reflect.Value) (err error) {
	s := w.stream
	t := rv.Type()
	classname := ClassManager.GetClassAlias(t)
	if classname == "" {
		classname = t.Name()
		ClassManager.Register(t, classname)
	}
	index, found := w.classref[classname]
	var fields []reflect.StructField
	if found {
		fields = w.fieldsref[index]
	} else {
		n := t.NumField()
		fields = make([]reflect.StructField, 0, n)
		for i := 0; i < n; i++ {
			if f := t.Field(i); !f.Anonymous && serializeType[f.Type.Kind()] {
				fields = append(fields, f)
			}
		}
		if index, err = w.writeClass(classname, fields); err != nil {
			return err
		}
	}
	w.setRef(v)
	if err = s.WriteByte(TagObject); err == nil {
		if _, err = s.WriteString(strconv.Itoa(index)); err == nil {
			if err = s.WriteByte(TagOpenbrace); err == nil {
				for _, f := range fields {
					if err = w.Serialize(rv.FieldByIndex(f.Index).Interface()); err != nil {
						return err
					}
				}
				err = w.stream.WriteByte(TagClosebrace)
			}
		}
	}
	return err
}

func (w *simpleWriter) writeClass(classname string, fields []reflect.StructField) (index int, err error) {
	s := w.stream
	count := len(fields)
	if err = s.WriteByte(TagClass); err != nil {
		return -1, err
	}
	if _, err = s.WriteString(strconv.Itoa(ulen(classname))); err != nil {
		return -1, err
	}
	if err = s.WriteByte(TagQuote); err != nil {
		return -1, err
	}
	if _, err = s.WriteString(classname); err != nil {
		return -1, err
	}
	if err = s.WriteByte(TagQuote); err != nil {
		return -1, err
	}
	if count > 0 {
		if _, err = s.WriteString(strconv.Itoa(count)); err != nil {
			return -1, err
		}
		if err = s.WriteByte(TagOpenbrace); err != nil {
			return -1, err
		}
		for _, f := range fields {
			if err = w.WriteString(firstLetterToLower(f.Name)); err != nil {
				return -1, err
			}
		}
		if err = s.WriteByte(TagClosebrace); err != nil {
			return -1, err
		}
	} else {
		if err = s.WriteByte(TagOpenbrace); err != nil {
			return -1, err
		}
		if err = s.WriteByte(TagClosebrace); err != nil {
			return -1, err
		}
	}
	index = len(w.fieldsref)
	w.classref[classname] = index
	w.fieldsref = append(w.fieldsref, fields)
	return index, nil
}

// private functions

func ulen(str string) (n int) {
	for _, char := range str {
		n++
		if char > rune3Max {
			n++
		}
	}
	return n
}

func formatDate(year int, month int, day int) []byte {
	var date [9]byte
	date[0] = TagDate
	date[1] = byte('0' + (year / 1000 % 10))
	date[2] = byte('0' + (year / 100 % 10))
	date[3] = byte('0' + (year / 10 % 10))
	date[4] = byte('0' + (year % 10))
	date[5] = byte('0' + (month / 10 % 10))
	date[6] = byte('0' + (month % 10))
	date[7] = byte('0' + (day / 10 % 10))
	date[8] = byte('0' + (day % 10))
	return date[:]
}

func formatTime(hour int, min int, sec int, nsec int) []byte {
	var time [7]byte
	time[0] = TagTime
	time[1] = byte('0' + (hour / 10 % 10))
	time[2] = byte('0' + (hour % 10))
	time[3] = byte('0' + (min / 10 % 10))
	time[4] = byte('0' + (min % 10))
	time[5] = byte('0' + (sec / 10 % 10))
	time[6] = byte('0' + (sec % 10))
	if nsec > 0 {
		if nsec%1000000 == 0 {
			var nanoSecond [4]byte
			nanoSecond[0] = TagPoint
			nanoSecond[1] = (byte)('0' + (nsec / 100000000 % 10))
			nanoSecond[2] = (byte)('0' + (nsec / 10000000 % 10))
			nanoSecond[3] = (byte)('0' + (nsec / 1000000 % 10))
			return append(time[:], nanoSecond[:]...)
		} else if nsec%1000 == 0 {
			var nanoSecond [7]byte
			nanoSecond[0] = TagPoint
			nanoSecond[1] = (byte)('0' + (nsec / 100000000 % 10))
			nanoSecond[2] = (byte)('0' + (nsec / 10000000 % 10))
			nanoSecond[3] = (byte)('0' + (nsec / 1000000 % 10))
			nanoSecond[4] = (byte)('0' + (nsec / 100000 % 10))
			nanoSecond[5] = (byte)('0' + (nsec / 10000 % 10))
			nanoSecond[6] = (byte)('0' + (nsec / 1000 % 10))
			return append(time[:], nanoSecond[:]...)

		} else {
			var nanoSecond [10]byte
			nanoSecond[0] = TagPoint
			nanoSecond[1] = (byte)('0' + (nsec / 100000000 % 10))
			nanoSecond[2] = (byte)('0' + (nsec / 10000000 % 10))
			nanoSecond[3] = (byte)('0' + (nsec / 1000000 % 10))
			nanoSecond[4] = (byte)('0' + (nsec / 100000 % 10))
			nanoSecond[5] = (byte)('0' + (nsec / 10000 % 10))
			nanoSecond[6] = (byte)('0' + (nsec / 1000 % 10))
			nanoSecond[7] = (byte)('0' + (nsec / 100 % 10))
			nanoSecond[8] = (byte)('0' + (nsec / 10 % 10))
			nanoSecond[9] = (byte)('0' + (nsec % 10))
			return append(time[:], nanoSecond[:]...)
		}
	}
	return time[:]
}

func firstLetterToLower(s string) string {
	if s == "" || s[0] < 'A' || s[0] > 'Z' {
		return s
	}
	b := ([]byte)(s)
	b[0] = b[0] - 'A' + 'a'
	return string(b)
}
