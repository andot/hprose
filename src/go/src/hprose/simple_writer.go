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
 * LastModified: Feb 3, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"container/list"
	"errors"
	"math"
	"math/big"
	"reflect"
	"strconv"
	"sync"
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

type field struct {
	Name  string
	Index []int
}

var writerFieldsCache struct {
	sync.RWMutex
	cache map[reflect.Type][]field
}

type writer struct {
	stream    BufWriter
	classref  map[string]int
	fieldsref [][]field
	writerRefer
	numbuf [20]byte
}

type fakeWriterRefer struct{}

func (r fakeWriterRefer) setRef(interface{}) {}

func (r fakeWriterRefer) writeRef(s BufWriter, v interface{}) (success bool, err error) {
	return false, nil
}

func (r fakeWriterRefer) resetRef() {}

func NewSimpleWriter(stream BufWriter) Writer {
	return &writer{
		stream:      stream,
		writerRefer: fakeWriterRefer{},
	}
}

func (w *writer) Stream() BufWriter {
	return w.stream
}

func (w *writer) Serialize(v interface{}) (err error) {
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
	return err
}

func (w *writer) WriteValue(v reflect.Value) error {
	return w.Serialize(v.Interface())
}

func (w *writer) WriteNull() error {
	return w.stream.WriteByte(TagNull)
}

func (w *writer) WriteInt8(v int8) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else if err = s.WriteByte(TagInteger); err == nil {
		if err = w.writeInt8(v); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *writer) WriteInt16(v int16) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else if err = s.WriteByte(TagInteger); err == nil {
		if err = w.writeInt16(v); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *writer) WriteInt32(v int32) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else if err = s.WriteByte(TagInteger); err == nil {
		if err = w.writeInt32(v); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *writer) WriteInt64(v int64) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else {
		if v >= math.MinInt32 && v <= math.MaxInt32 {
			err = s.WriteByte(TagInteger)
		} else {
			err = s.WriteByte(TagLong)
		}
		if err == nil {
			if err = w.writeInt64(v); err == nil {
				err = s.WriteByte(TagSemicolon)
			}
		}
	}
	return err
}

func (w *writer) WriteUint8(v uint8) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else if err = s.WriteByte(TagInteger); err == nil {
		if err = w.writeUint8(v); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *writer) WriteUint16(v uint16) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else if err = s.WriteByte(TagInteger); err == nil {
		if err = w.writeUint16(v); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *writer) WriteUint32(v uint32) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else {
		if v <= math.MaxInt32 {
			err = s.WriteByte(TagInteger)
		} else {
			err = s.WriteByte(TagLong)
		}
		if err == nil {
			if err = w.writeUint32(v); err == nil {
				err = s.WriteByte(TagSemicolon)
			}
		}
	}
	return err
}

func (w *writer) WriteUint64(v uint64) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else {
		if v <= math.MaxInt32 {
			err = s.WriteByte(TagInteger)
		} else {
			err = s.WriteByte(TagLong)
		}
		if err == nil {
			if err = w.writeUint64(v); err == nil {
				err = s.WriteByte(TagSemicolon)
			}
		}
	}
	return err
}

func (w *writer) WriteInt(v int) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else {
		if v >= math.MinInt32 && v <= math.MaxInt32 {
			err = s.WriteByte(TagInteger)
		} else {
			err = s.WriteByte(TagLong)
		}
		if err == nil {
			if err = w.writeInt(v); err == nil {
				err = s.WriteByte(TagSemicolon)
			}
		}
	}
	return err
}

func (w *writer) WriteUint(v uint) (err error) {
	s := w.Stream()
	if v >= 0 && v <= 9 {
		err = s.WriteByte(byte(v + '0'))
	} else {
		if v <= math.MaxInt32 {
			err = s.WriteByte(TagInteger)
		} else {
			err = s.WriteByte(TagLong)
		}
		if err == nil {
			if err = w.writeUint(v); err == nil {
				err = s.WriteByte(TagSemicolon)
			}
		}
	}
	return err
}

func (w *writer) WriteBigInt(v *big.Int) (err error) {
	s := w.stream
	if err = s.WriteByte(TagLong); err == nil {
		if _, err = s.WriteString(v.String()); err == nil {
			err = s.WriteByte(TagSemicolon)
		}
	}
	return err
}

func (w *writer) WriteFloat32(v float32) error {
	return w.WriteFloat64(float64(v))
}

func (w *writer) WriteFloat64(v float64) (err error) {
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

func (w *writer) WriteNaN() error {
	return w.stream.WriteByte(TagNaN)
}

func (w *writer) WriteInfinity(pos bool) (err error) {
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

func (w *writer) WriteBool(v bool) error {
	s := w.stream
	if v {
		return s.WriteByte(TagTrue)
	}
	return s.WriteByte(TagFalse)
}

func (w *writer) WriteTime(v time.Time) (err error) {
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

func (w *writer) WriteTimeWithRef(v time.Time) error {
	if success, err := w.writeRef(w.stream, v); err == nil && !success {
		return w.WriteTime(v)
	} else {
		return err
	}
}

func (w *writer) WriteEmpty() error {
	return w.stream.WriteByte(TagEmpty)
}

func (w *writer) WriteUTF8Char(v string) (err error) {
	s := w.stream
	if err = s.WriteByte(TagUTF8Char); err == nil {
		_, err = s.WriteString(v)
	}
	return err
}

func (w *writer) WriteString(v string) (err error) {
	w.setRef(v)
	s := w.stream
	if err = s.WriteByte(TagString); err == nil {
		if length := ulen(v); length > 0 {
			if err = w.writeInt(length); err == nil {
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

func (w *writer) WriteStringWithRef(v string) error {
	if success, err := w.writeRef(w.stream, v); err == nil && !success {
		return w.WriteString(v)
	} else {
		return err
	}
}

func (w *writer) WriteBytes(v *[]byte) (err error) {
	w.setRef(v)
	s := w.stream
	if err = s.WriteByte(TagBytes); err == nil {
		if length := len(*v); length > 0 {
			if err = w.writeInt(length); err == nil {
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

func (w *writer) WriteBytesWithRef(v *[]byte) error {
	if success, err := w.writeRef(w.stream, v); err == nil && !success {
		return w.WriteBytes(v)
	} else {
		return err
	}
}

func (w *writer) WriteUUID(v *uuid.UUID) (err error) {
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

func (w *writer) WriteUUIDWithRef(v *uuid.UUID) error {
	if success, err := w.writeRef(w.stream, v); err == nil && !success {
		return w.WriteUUID(v)
	} else {
		return err
	}
}

func (w *writer) WriteList(v *list.List) (err error) {
	w.setRef(v)
	s := w.stream
	count := v.Len()
	if err = s.WriteByte(TagList); err == nil {
		if count > 0 {
			if err = w.writeInt(count); err == nil {
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

func (w *writer) WriteListWithRef(v *list.List) error {
	if success, err := w.writeRef(w.stream, v); err == nil && !success {
		return w.WriteList(v)
	} else {
		return err
	}
}

func (w *writer) WriteArray(v []reflect.Value) (err error) {
	s := w.Stream()
	count := len(v)
	if err = s.WriteByte(TagList); err == nil {
		if count > 0 {
			if err = w.writeInt(count); err == nil {
				if err = s.WriteByte(TagOpenbrace); err == nil {
					for i := 0; i < count; i++ {
						if err = w.WriteValue(v[i]); err != nil {
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

func (w *writer) WriteSlice(v interface{}) error {
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

func (w *writer) WriteSliceWithRef(v interface{}) error {
	if success, err := w.writeRef(w.stream, v); err == nil && !success {
		return w.WriteSlice(v)
	} else {
		return err
	}
}

func (w *writer) WriteMap(v interface{}) error {
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

func (w *writer) WriteMapWithRef(v interface{}) error {
	if success, err := w.writeRef(w.stream, v); err == nil && !success {
		return w.WriteMap(v)
	} else {
		return err
	}
}

func (w *writer) WriteObject(v interface{}) error {
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

func (w *writer) WriteObjectWithRef(v interface{}) error {
	if success, err := w.writeRef(w.stream, v); err == nil && !success {
		return w.WriteObject(v)
	} else {
		return err
	}
}

func (w *writer) Reset() {
	if w.classref != nil {
		w.classref = make(map[string]int, cap(w.fieldsref))
		w.fieldsref = w.fieldsref[:0]
	}
	w.resetRef()
}

// private methods

func (w *writer) writeComplexData(v interface{}) (err error) {
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

func (w *writer) writeSliceValue(v reflect.Value) (err error) {
	s := w.Stream()
	count := v.Len()
	if err = s.WriteByte(TagList); err == nil {
		if count > 0 {
			if err = w.writeInt(count); err == nil {
				if err = s.WriteByte(TagOpenbrace); err == nil {
					for i := 0; i < count; i++ {
						if err = w.WriteValue(v.Index(i)); err != nil {
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

func (w *writer) writeMapValue(v reflect.Value) (err error) {
	s := w.Stream()
	count := v.Len()
	if err = s.WriteByte(TagMap); err == nil {
		if count > 0 {
			if err = w.writeInt(count); err == nil {
				if err = s.WriteByte(TagOpenbrace); err == nil {
					keys := v.MapKeys()
					for _, key := range keys {
						if err = w.WriteValue(key); err != nil {
							return err
						}
						if err = w.WriteValue(v.MapIndex(key)); err != nil {
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

func (w *writer) writeObjectValue(v interface{}, rv reflect.Value) (err error) {
	s := w.stream
	t := rv.Type()
	classname := ClassManager.GetClassAlias(t)
	if classname == "" {
		classname = t.Name()
		ClassManager.Register(t, classname)
	}
	if w.classref == nil {
		w.classref = make(map[string]int, 16)
		w.fieldsref = make([][]field, 0, 16)
	}
	index, found := w.classref[classname]
	var fields []field
	if found {
		fields = w.fieldsref[index]
	} else {
		writerFieldsCache.RLock()
		fields, found = writerFieldsCache.cache[t]
		writerFieldsCache.RUnlock()
		if !found {
			n := t.NumField()
			fields = make([]field, 0, n)
			for i := 0; i < n; i++ {
				if f := t.Field(i); !f.Anonymous && serializeType[f.Type.Kind()] {
					fields = append(fields, field{firstLetterToLower(f.Name), f.Index})
				}
			}
			writerFieldsCache.Lock()
			if writerFieldsCache.cache == nil {
				writerFieldsCache.cache = make(map[reflect.Type][]field)
			}
			writerFieldsCache.cache[t] = fields
			writerFieldsCache.Unlock()
		}
		if index, err = w.writeClass(classname, fields); err != nil {
			return err
		}
	}
	w.setRef(v)
	if err = s.WriteByte(TagObject); err == nil {
		if err = w.writeInt(index); err == nil {
			if err = s.WriteByte(TagOpenbrace); err == nil {
				for _, f := range fields {
					if err = w.WriteValue(rv.FieldByIndex(f.Index)); err != nil {
						return err
					}
				}
				err = w.stream.WriteByte(TagClosebrace)
			}
		}
	}
	return err
}

func (w *writer) writeClass(classname string, fields []field) (index int, err error) {
	s := w.stream
	count := len(fields)
	if err = s.WriteByte(TagClass); err != nil {
		return -1, err
	}
	if err = w.writeInt(ulen(classname)); err != nil {
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
		if err = w.writeInt(count); err != nil {
			return -1, err
		}
		if err = s.WriteByte(TagOpenbrace); err != nil {
			return -1, err
		}
		for _, f := range fields {
			if err = w.WriteString(f.Name); err != nil {
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

func (w *writer) writeInt(i int) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		sign := 1
		if i < 0 {
			sign = -sign
		}
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i%10)*sign + '0')
			i /= 10
		}
		if sign == -1 {
			off--
			w.numbuf[off] = '-'
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeInt8(i int8) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		sign := int8(1)
		if i < 0 {
			sign = -sign
		}
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i%10)*sign + '0')
			i /= 10
		}
		if sign == -1 {
			off--
			w.numbuf[off] = '-'
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeInt16(i int16) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		sign := int16(1)
		if i < 0 {
			sign = -sign
		}
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i%10)*sign + '0')
			i /= 10
		}
		if sign == -1 {
			off--
			w.numbuf[off] = '-'
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeInt32(i int32) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		sign := int32(1)
		if i < 0 {
			sign = -sign
		}
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i%10)*sign + '0')
			i /= 10
		}
		if sign == -1 {
			off--
			w.numbuf[off] = '-'
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeInt64(i int64) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		sign := int64(1)
		if i < 0 {
			sign = -sign
		}
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i%10)*sign + '0')
			i /= 10
		}
		if sign == -1 {
			off--
			w.numbuf[off] = '-'
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeUint(i uint) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i % 10) + '0')
			i /= 10
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeUint8(i uint8) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i % 10) + '0')
			i /= 10
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeUint16(i uint16) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i % 10) + '0')
			i /= 10
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeUint32(i uint32) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i % 10) + '0')
			i /= 10
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
}

func (w *writer) writeUint64(i uint64) error {
	if i >= 0 && i <= 9 {
		return w.stream.WriteByte((byte)(i + '0'))
	} else {
		off := 20
		for i != 0 {
			off--
			w.numbuf[off] = (byte)((i % 10) + '0')
			i /= 10
		}
		_, err := w.stream.Write(w.numbuf[off:])
		return err
	}
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
