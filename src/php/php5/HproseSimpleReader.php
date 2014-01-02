<?php
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
 * HproseSimpleReader.php                                 *
 *                                                        *
 * hprose simple reader class for php5.                   *
 *                                                        *
 * LastModified: Jan 2, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require_once('HproseClassManager.php');
require_once('HproseRawReader.php');

class HproseSimpleReader extends HproseRawReader {
    private $classref;
    function __construct(&$stream) {
        parent::__construct($stream);
        $this->classref = array();
    }
    public function &unserialize($tag = NULL) {
        if (is_null($tag)) {
            $tag = $this->stream->getc();
        }
        $result = NULL;
        switch ($tag) {
            case '0': $result = 0; break;
            case '1': $result = 1; break;
            case '2': $result = 2; break;
            case '3': $result = 3; break;
            case '4': $result = 4; break;
            case '5': $result = 5; break;
            case '6': $result = 6; break;
            case '7': $result = 7; break;
            case '8': $result = 8; break;
            case '9': $result = 9; break;
            case HproseTags::TagInteger: $result = $this->readIntegerWithoutTag(); break;
            case HproseTags::TagLong: $result = $this->readLongWithoutTag(); break;
            case HproseTags::TagDouble: $result = $this->readDoubleWithoutTag(); break;
            case HproseTags::TagNull: break;
            case HproseTags::TagEmpty: $result = ''; break;
            case HproseTags::TagTrue: $result = true; break;
            case HproseTags::TagFalse: $result = false; break;
            case HproseTags::TagNaN: $result = log(-1); break;
            case HproseTags::TagInfinity: $result = $this->readInfinityWithoutTag(); break;
            case HproseTags::TagDate: $result = $this->readDateWithoutTag(); break;
            case HproseTags::TagTime: $result = $this->readTimeWithoutTag(); break;
            case HproseTags::TagBytes: $result = $this->readBytesWithoutTag(); break;
            case HproseTags::TagUTF8Char: $result = $this->readUTF8CharWithoutTag(); break;            
            case HproseTags::TagString: $result = $this->readStringWithoutTag(); break;
            case HproseTags::TagGuid: $result = $this->readGuidWithoutTag(); break;
            case HproseTags::TagList: $result = &$this->readListWithoutTag(); break;
            case HproseTags::TagMap: $result = &$this->readMapWithoutTag(); break;
            case HproseTags::TagClass: $this->readClass(); $result = $this->readObject(); break;
            case HproseTags::TagObject: $result = $this->readObjectWithoutTag(); break;
            case HproseTags::TagRef:  $result = &$this->readRef(); break;
            case HproseTags::TagError: throw new HproseException($this->readString());
            default: $this->unexpectedTag($tag);
        }
        return $result;
    }
    public function checkTag($expectTag, $tag = NULL) {
        if (is_null($tag)) $tag = $this->stream->getc();
        if ($tag != $expectTag) $this->unexpectedTag($tag, $expectTag);
    }
    public function checkTags($expectTags, $tag = NULL) {
        if (is_null($tag)) $tag = $this->stream->getc();
        if (!in_array($tag, $expectTags)) {
            $this->unexpectedTag($tag, implode('', $expectTags));
        }
        return $tag;
    }
    public function readIntegerWithoutTag() {
        return (int)($this->stream->readuntil(HproseTags::TagSemicolon));
    }
    public function readInteger() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags::TagInteger: return $this->readIntegerWithoutTag();
            default: $this->unexpectedTag($tag);
        }
    }
    public function readLongWithoutTag() {
        return $this->stream->readuntil(HproseTags::TagSemicolon);
    }
    public function readLong() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags::TagInteger:
            case HproseTags::TagLong: return $this->readLongWithoutTag();
            default: $this->unexpectedTag($tag);
        }
    }
    public function readDoubleWithoutTag() {
        return (double)($this->stream->readuntil(HproseTags::TagSemicolon));
    }
    public function readDouble($includeTag = false) {
        $tag = $this->stream->getc();
        switch ($tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags::TagInteger:
            case HproseTags::TagLong:
            case HproseTags::TagDouble: return $this->readDoubleWithoutTag();
            case HproseTags::TagNaN: return log(-1);
            case hproseTags::TagInfinity: return $this->readInfinityWithoutTag();
            default: $this->unexpectedTag($tag);
        }
    }
    public function readNaN() {
        $this->checkTag(HproseTags::TagNaN);
        return log(-1);
    }
    public function readInfinityWithoutTag() {
        return (($this->stream->getc() == HproseTags::TagNeg) ? log(0) : -log(0));
    }
    public function readInfinity($includeTag = false) {
        $this->checkTag(HproseTags::TagInfinity);
        return $this->readInfinityWithoutTag();
    }
    public function readNull() {
        $this->checkTag(HproseTags::TagNull);
        return NULL;
    }
    public function readEmpty() {
        $this->checkTag(HproseTags::TagEmpty);
        return '';
    }
    public function readBoolean() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagTrue: return true;
            case HproseTags::TagFalse: return false;
            default: $this->unexpectedTag($tag);
        }
    }
    public function readDateWithoutTag() {
        $year = (int)($this->stream->read(4));
        $month = (int)($this->stream->read(2));
        $day = (int)($this->stream->read(2));
        $tag = $this->stream->getc();
        if ($tag == HproseTags::TagTime) {
            $hour = (int)($this->stream->read(2));
            $minute = (int)($this->stream->read(2));
            $second = (int)($this->stream->read(2));
            $microsecond = 0;
            $tag = $this->stream->getc();
            if ($tag == HproseTags::TagPoint) {
                $microsecond = (int)($this->stream->read(3)) * 1000;
                $tag = $this->stream->getc();
                if (($tag >= '0') && ($tag <= '9')) {
                    $microsecond += (int)($tag) * 100 + (int)($this->stream->read(2));
                    $tag = $this->stream->getc();
                    if (($tag >= '0') && ($tag <= '9')) {
                        $this->stream->skip(2);
                        $tag = $this->stream->getc();
                    }
                }
            }
            if ($tag == HproseTags::TagUTC) {
                $date = new HproseDateTime($year, $month, $day,
                                            $hour, $minute, $second,
                                            $microsecond, true);
            }
            else {
                $date = new HproseDateTime($year, $month, $day,
                                            $hour, $minute, $second,
                                            $microsecond);
            }
        }
        elseif ($tag == HproseTags::TagUTC) {
            $date = new HproseDate($year, $month, $day, true);            
        }
        else {
            $date = new HproseDate($year, $month, $day);
        }
        return $date;
    }
    public function readDate() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagDate: return $this->readDateWithoutTag();
            case HproseTags::TagRef: return $this->readRef();
            default: $this->unexpectedTag($tag);
        }
    }
    public function readTimeWithoutTag() {
        $hour = (int)($this->stream->read(2));
        $minute = (int)($this->stream->read(2));
        $second = (int)($this->stream->read(2));
        $microsecond = 0;
        $tag = $this->stream->getc();
        if ($tag == HproseTags::TagPoint) {
            $microsecond = (int)($this->stream->read(3)) * 1000;
            $tag = $this->stream->getc();
            if (($tag >= '0') && ($tag <= '9')) {
                $microsecond += (int)($tag) * 100 + (int)($this->stream->read(2));
                $tag = $this->stream->getc();
                if (($tag >= '0') && ($tag <= '9')) {
                    $this->stream->skip(2);
                    $tag = $this->stream->getc();
                }
            }
        }
        if ($tag == HproseTags::TagUTC) {
            $time = new HproseTime($hour, $minute, $second, $microsecond, true);
        }
        else {
            $time = new HproseTime($hour, $minute, $second, $microsecond);
        }
        return $time;
    }
    public function readTime() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagTime: return $this->readTimeWithoutTag();
            case HproseTags::TagRef: return $this->readRef();
            default: $this->unexpectedTag($tag);
        }
    }
    public function readBytesWithoutTag() {
        $count = (int)($this->stream->readuntil(HproseTags::TagQuote));
        $bytes = $this->stream->read($count);
        $this->stream->skip(1);
        return $bytes;
    }
    public function readBytes() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagBytes: return $this->readBytesWithoutTag();
            case HproseTags::TagRef: return $this->readRef();
            default: $this->unexpectedTag($tag);
        }
    }
    public function readUTF8CharWithoutTag() {
        $c = $this->stream->getc();
        $s = $c;
        $a = ord($c);
        if (($a & 0xE0) == 0xC0) {
            $s .= $this->stream->getc();
        }
        elseif (($a & 0xF0) == 0xE0) {
            $s .= $this->stream->read(2);
        }
        elseif ($a > 0x7F) {
            throw new HproseException("bad utf-8 encoding");
        }
        return $s;
    }
    public function readUTF8Char() {
        $this->checkTag(HproseTags::TagUTF8Char);
        return $this->readUTF8CharWithoutTag();
    }
    public function readStringWithoutTag() {
        $len = (int)$this->stream->readuntil(HproseTags::TagQuote);
        $this->stream->mark();
        $utf8len = 0;
        for ($i = 0; $i < $len; ++$i) {
            switch (ord($this->stream->getc()) >> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7: {
                    // 0xxx xxxx
                    $utf8len++;
                    break;
                }
                case 12:
                case 13: {
                    // 110x xxxx   10xx xxxx
                    $this->stream->skip(1);
                    $utf8len += 2;
                    break;
                }
                case 14: {
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    $this->stream->skip(2);
                    $utf8len += 3;
                    break;
                }
                case 15: {
                    // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                    $this->stream->skip(3);
                    $utf8len += 4;
                    ++$i;
                    break;
                }
                default: {
                    throw new HproseException('bad utf-8 encoding');
                }
            }
        }
        $this->stream->reset();
        $this->stream->unmark();
        $s = $this->stream->read($utf8len);
        $this->stream->skip(1);
        return $s;
    }
    public function readString() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagString: return $this->readStringWithoutTag();
            case HproseTags::TagRef: return $this->readRef();
            default: $this->unexpectedTag($tag);
        }
    }
    public function readGuidWithoutTag() {
        $this->stream->skip(1);
        $s = $this->stream->read(36);
        $this->stream->skip(1);
        return $s;
    }
    public function readGuid() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagGuid: return $this->readGuidWithoutTag();
            case HproseTags::TagRef: return $this->readRef();
            default: $this->unexpectedTag($tag);
        }
    }
    protected function &readListBegin() {
        $list = array();
        return $list;
    }
    protected function &readListEnd(&$list) {
        $count = (int)$this->stream->readuntil(HproseTags::TagOpenbrace);
        for ($i = 0; $i < $count; ++$i) {
            $list[] = &$this->unserialize();
        }
        $this->stream->skip(1);
        return $list;
    }
    public function &readListWithoutTag() {
        $list = &$this->readListBegin();
        return $this->readListEnd($list);
    }
    public function &readList() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagList: return $this->readListWithoutTag();
            case HproseTags::TagRef: return $this->readRef();
            default: $this->unexpectedTag($tag);
        }
    }
    protected function &readMapBegin() {
        $map = array();
        return $map;
    }
    protected function &readMapEnd(&$map) {
        $count = (int)$this->stream->readuntil(HproseTags::TagOpenbrace);
        for ($i = 0; $i < $count; ++$i) {
            $key = &$this->unserialize();
            $map[$key] = &$this->unserialize();
        }
        $this->stream->skip(1);
        return $map;
    }
    public function &readMapWithoutTag() {
        $map = &$this->readMapBegin();
        return $this->readMapEnd($map);
    }
    public function &readMap() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagMap: return $this->readMapWithoutTag();
            case HproseTags::TagRef: return $this->readRef();
            default: $this->unexpectedTag($tag);
        }
    }
    protected function readObjectBegin() {
        list($classname, $fields) = $this->classref[(int)$this->stream->readuntil(HproseTags::TagOpenbrace)];
        $object = new $classname;
        return array($object, $fields);
    }
    protected function readObjectEnd($object, $fields) {
        $count = count($fields);
        if (class_exists('ReflectionClass')) {
            $reflector = new ReflectionClass($object);
            for ($i = 0; $i < $count; ++$i) {
                $field = $fields[$i];
                if ($reflector->hasProperty($field)) {
                    $property = $reflector->getProperty($field);
                    $property->setAccessible(true);
                    $property->setValue($object, $this->unserialize());
                }
                else {
                    $object->$field = &$this->unserialize();
                }
            }
        }
        else {
            for ($i = 0; $i < $count; ++$i) {
                $object->$fields[$i] = &$this->unserialize();
            }
        }
        $this->stream->skip(1);
        return $object;
    }
    public function readObjectWithoutTag() {
        list($object, $fields) = $this->readObjectBegin();
        return $this->readObjectEnd($object, $fields);
    }
    public function readObject() {
        $tag = $this->stream->getc();
        switch ($tag) {
            case HproseTags::TagClass: $this->readclass(); return $this->readObject();
            case HproseTags::TagObject: return $this->readObjectWithoutTag();
            case HproseTags::TagRef: return $this->readRef();
            default: $this->unexpectedTag($tag);
        }
    }
    protected function readClass() {
        $classname = HproseClassManager::getClass(self::readStringWithoutTag());
        $count = (int)$this->stream->readuntil(HproseTags::TagOpenbrace);
        $fields = array();
        for ($i = 0; $i < $count; ++$i) {
            $fields[] = $this->readString();
        }
        $this->stream->skip(1);
        $this->classref[] = array($classname, $fields);
    }
    protected function &readRef() {
        $this->unexpectedTag(HproseTags::TagRef);
    }
    public function reset() {
        $this->classref = array();
    }
}

?>