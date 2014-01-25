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
 * hprose/writer_test.go                                  *
 *                                                        *
 * hprose Writer Test for Go.                             *
 *                                                        *
 * LastModified: Jan 21, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"bytes"
	"container/list"
	//"math"
	//"math/big"
	"testing"
	"time"
	"uuid"
)

func TestReaderTime(t *testing.T) {
	b := new(bytes.Buffer)
	writer := NewWriter(b)
	writer.Serialize(time.Date(2014, 1, 19, 20, 25, 33, 12345678, time.UTC))
	writer.Serialize(time.Date(2014, 1, 19, 20, 25, 33, 12345678, time.UTC))
	writer.Serialize(time.Date(2014, 1, 19, 0, 0, 0, 0, time.Local))
	writer.Serialize(time.Date(1, 1, 1, 1, 1, 1, 0, time.Local))
	if b.String() != "D20140119T202533.012345678Zr0;D20140119;T010101;" {
		t.Error(b.String())
	}
	reader := NewReader(b)
	var ti time.Time
	reader.Unserialize(&ti)
	reader.Unserialize(&ti)
	reader.Unserialize(&ti)
	reader.Unserialize(&ti)
}

func TestReaderString(t *testing.T) {
	b := new(bytes.Buffer)
	writer := NewWriter(b)
	writer.Serialize("")
	writer.Serialize("我爱你")
	writer.Serialize("我爱你")

	if b.String() != `es3"我爱你"r0;` {
		t.Error(b.String())
	}
	reader := NewReader(b)
	var s string
	reader.Unserialize(&s)
	reader.Unserialize(&s)
	reader.Unserialize(&s)
}

func TestReaderBytes(t *testing.T) {
	b := new(bytes.Buffer)
	writer := NewWriter(b)
	writer.Serialize([]byte(""))
	bb := []byte("我爱你")
	writer.Serialize(&bb)
	writer.Serialize(&bb)
	if b.String() != `eb9"我爱你"r0;` {
		t.Error(b.String())
	}
	reader := NewReader(b)
	reader.Unserialize(&bb)
	reader.Unserialize(&bb)
	reader.Unserialize(&bb)
}

func TestReaderUUID(t *testing.T) {
	b := new(bytes.Buffer)
	writer := NewWriter(b)
	u := uuid.Parse("3f257da1-0b85-48d6-8f5c-6cd13d2d60c9")
	writer.Serialize(&u)
	writer.Serialize(&u)
	writer.Serialize(&u)
	if b.String() != "g{3f257da1-0b85-48d6-8f5c-6cd13d2d60c9}r0;r0;" {
		t.Error(b.String())
	}
	var u2, u3 *uuid.UUID
	reader := NewReader(b)
	reader.Unserialize(&u)
	reader.Unserialize(&u2)
	reader.Unserialize(&u3)
	if u2 != u3 {
		t.Error(u, u2, u3)
	}
}

func TestReaderList(t *testing.T) {
	b := new(bytes.Buffer)
	writer := NewWriter(b)
	a := list.New()
	a.PushBack(1)
	a.PushBack(2)
	a.PushBack(3)
	writer.Serialize(*a)
	writer.Serialize(a)
	var aa interface{} = a
	writer.Serialize(aa)
	if b.String() != "a3{123}a3{123}r1;" {
		t.Error(b.String())
	}
	reader := NewReader(b)
	reader.Unserialize(&a)
	reader.Unserialize(&a)
	reader.Unserialize(&aa)
}

func TestReaderSlice(t *testing.T) {
	b := new(bytes.Buffer)
	writer := NewWriter(b)
	a := []int{0, 1, 2}
	writer.Serialize(a)
	writer.Serialize(&a)
	var aa interface{} = &a
	writer.Serialize(aa)
	if b.String() != "a3{012}a3{012}r1;" {
		t.Error(b.String())
	}
	reader := NewReader(b)
	reader.Unserialize(&a)
	reader.Unserialize(&a)
	reader.Unserialize(&aa)
}

func TestReaderMap(t *testing.T) {
	b := new(bytes.Buffer)
	writer := NewWriter(b)
	m := make(map[string]interface{})
	m["name"] = "马秉尧"
	m["age"] = 33
	m["male"] = true
	writer.Serialize(m)
	writer.Serialize(&m)
	var mm interface{} = &m
	writer.Serialize(mm)
	s := `m3{s4"name"s3"马秉尧"s3"age"i33;s4"male"t}m3{r1;r2;r3;i33;r4;t}r5;`
	if b.String() != s {
		t.Error(b.String())
	}
	reader := NewReader(b)
	reader.Unserialize(&m)
	reader.Unserialize(&m)
	reader.Unserialize(&mm)
}

func TestReaderObject(t *testing.T) {
	b := new(bytes.Buffer)
	writer := NewWriter(b)
	p := testPerson{"马秉尧", 33, true}
	writer.Serialize(p)
	writer.Serialize(&p)
	writer.Serialize(&p)
	var pp interface{} = &p
	writer.Serialize(pp)
	s := `c10"testPerson"3{s4"name"s3"age"s4"male"}o0{s3"马秉尧"i33;t}o0{r4;i33;t}r5;r5;`
	if b.String() != s {
		t.Error(b.String())
	}
	reader := NewReader(b)
	reader.Unserialize(&p)
	reader.Unserialize(&pp)
	reader.Unserialize(&pp)
	reader.Unserialize(&p)
}
