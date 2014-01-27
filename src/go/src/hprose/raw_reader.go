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
 * hprose/raw_reader.go                                   *
 *                                                        *
 * hprose RawReader for Go.                               *
 *                                                        *
 * LastModified: Jan 27, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bufio"
	"bytes"
	"errors"
	"io"
	"strings"
)

type RawReader struct {
	stream *bufio.Reader
}

func NewRawReader(stream io.Reader) *RawReader {
	return &RawReader{stream: bufio.NewReader(stream)}
}

func (r *RawReader) ReadRaw() (raw []byte, err error) {
	ostream := new(bytes.Buffer)
	err = r.readRawTo(ostream)
	return ostream.Bytes(), err
}

func (r *RawReader) readRawTo(ostream *bytes.Buffer) (err error) {
	var tag byte
	if tag, err = r.stream.ReadByte(); err == nil {
		err = r.readRaw(ostream, tag)
	}
	return err
}

func (r *RawReader) readRaw(ostream *bytes.Buffer, tag byte) (err error) {
	switch tag {
	case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
		TagNull, TagEmpty, TagTrue, TagFalse, TagNaN:
		err = ostream.WriteByte(tag)
	case TagInfinity:
		if err = ostream.WriteByte(tag); err == nil {
			if tag, err = r.stream.ReadByte(); err == nil {
				err = ostream.WriteByte(tag)
			}
		}
	case TagInteger, TagLong, TagDouble, TagRef:
		err = r.readNumberRaw(ostream, tag)
	case TagDate, TagTime:
		err = r.readDateTimeRaw(ostream, tag)
	case TagUTF8Char:
		err = r.readUTF8CharRaw(ostream, tag)
	case TagBytes:
		err = r.readBytesRaw(ostream, tag)
	case TagString:
		err = r.readStringRaw(ostream, tag)
	case TagGuid:
		err = r.readGuidRaw(ostream, tag)
	case TagList, TagMap, TagObject:
		err = r.readComplexRaw(ostream, tag)
	case TagClass:
		if err = r.readComplexRaw(ostream, tag); err == nil {
			err = r.readRawTo(ostream)
		}
	case TagError:
		if err = ostream.WriteByte(tag); err == nil {
			err = r.readRawTo(ostream)
		}
	default:
		err = unexpectedTag(tag, nil)
	}
	return err
}

func (r *RawReader) readNumberRaw(ostream *bytes.Buffer, tag byte) (err error) {
	err = ostream.WriteByte(tag)
	for err == nil {
		if tag, err = r.stream.ReadByte(); err == nil {
			if err = ostream.WriteByte(tag); tag == TagSemicolon {
				break
			}
		}
	}
	return err
}

func (r *RawReader) readDateTimeRaw(ostream *bytes.Buffer, tag byte) (err error) {
	err = ostream.WriteByte(tag)
	for err == nil {
		if tag, err = r.stream.ReadByte(); err == nil {
			if err = ostream.WriteByte(tag); tag == TagSemicolon || tag == TagUTC {
				break
			}
		}
	}
	return err
}

func (r *RawReader) readUTF8CharRaw(ostream *bytes.Buffer, tag byte) (err error) {
	if err = ostream.WriteByte(tag); err == nil {
		var c rune
		if c, _, err = r.stream.ReadRune(); err == nil {
			_, err = ostream.WriteRune(c)
		}
	}
	return err
}

func (r *RawReader) readBytesRaw(ostream *bytes.Buffer, tag byte) (err error) {
	err = ostream.WriteByte(tag)
	count := 0
	tag = '0'
	for err == nil {
		count *= 10
		count += int(tag - '0')
		if tag, err = r.stream.ReadByte(); err == nil {
			if err = ostream.WriteByte(tag); tag == TagQuote {
				break
			}
		}
	}
	if err == nil {
		b := make([]byte, count+1)
		if _, err = r.stream.Read(b); err == nil {
			_, err = ostream.Write(b)
		}
	}
	return err
}

func (r *RawReader) readStringRaw(ostream *bytes.Buffer, tag byte) (err error) {
	err = ostream.WriteByte(tag)
	count := 0
	tag = '0'
	for err == nil {
		count *= 10
		count += int(tag - '0')
		if tag, err = r.stream.ReadByte(); err == nil {
			if err = ostream.WriteByte(tag); tag == TagQuote {
				break
			}
		}
	}
	if err == nil {
		var str string
		if str, err = r.readUTF8String(count + 1); err == nil {
			_, err = ostream.WriteString(str)
		}
	}
	return err
}

func (r *RawReader) readGuidRaw(ostream *bytes.Buffer, tag byte) (err error) {
	if err = ostream.WriteByte(tag); err == nil {
		if guid, err := r.stream.Peek(38); err == nil {
			_, err = ostream.Write(guid)
		}
	}
	return err
}

func (r *RawReader) readComplexRaw(ostream *bytes.Buffer, tag byte) (err error) {
	err = ostream.WriteByte(tag)
	for err == nil && tag != TagOpenbrace {
		if tag, err = r.stream.ReadByte(); err == nil {
			err = ostream.WriteByte(tag)
		}
	}
	if err == nil {
		tag, err = r.stream.ReadByte()
	}
	for err == nil && tag != TagClosebrace {
		if err = r.readRaw(ostream, tag); err == nil {
			tag, err = r.stream.ReadByte()
		}
	}
	if err == nil {
		err = ostream.WriteByte(tag)
	}
	return err
}

func (r *RawReader) readUTF8String(length int) (str string, err error) {
	s := r.stream
	n := 96
	if length == 0 {
		return "", nil
	} else if length == 1 {
		n = 3
	} else if length > 48 {
		n = length * 2
	}
	buf := bytes.NewBuffer(make([]byte, 0, n))
	for i := 0; i < length; i++ {
		var c byte
		c, err = s.ReadByte()
		if err != nil {
			return "", err
		}
		switch c >> 4 {
		case 0, 1, 2, 3, 4, 5, 6, 7:
			buf.WriteByte(c)
		case 12, 13:
			buf.WriteByte(c)
			c, err = s.ReadByte()
			if err != nil {
				return "", err
			}
			buf.WriteByte(c)
		case 14:
			buf.WriteByte(c)
			c, err = s.ReadByte()
			if err != nil {
				return "", err
			}
			buf.WriteByte(c)
			c, err = s.ReadByte()
			if err != nil {
				return "", err
			}
			buf.WriteByte(c)
		case 15:
			buf.WriteByte(c)
			c, err = s.ReadByte()
			if err != nil {
				return "", err
			}
			buf.WriteByte(c)
			c, err = s.ReadByte()
			if err != nil {
				return "", err
			}
			buf.WriteByte(c)
			c, err = s.ReadByte()
			if err != nil {
				return "", err
			}
			buf.WriteByte(c)
			i++
		default:
			return "", badEncodeError
		}
	}
	return string(buf.Bytes()), nil
}

// private functions

func unexpectedTag(tag byte, expectTags []byte) error {
	if t := string([]byte{tag}); expectTags == nil {
		return errors.New("Unexpected serialize tag '" + t + "' in stream")
	} else if e := string(expectTags); strings.IndexByte(e, tag) < 0 {
		return errors.New("Tag '" + e + "' expected, but '" + t + "' found in stream")
	}
	return nil
}
