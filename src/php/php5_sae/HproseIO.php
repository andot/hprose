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
 * HproseIO.php                                           *
 *                                                        *
 * hprose io stream library for php5.                     *
 *                                                        *
 * LastModified: Dec 27, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require_once('HproseCommon.php');

abstract class HproseAbstractStream {
    public abstract function close();
    public abstract function getc();
    public abstract function read($length);
    public abstract function readuntil($char);
    public abstract function seek($offset, $whence = SEEK_SET);
    public abstract function mark();
    public abstract function unmark();
    public abstract function reset();    
    public abstract function skip($n);
    public abstract function eof();
    public abstract function write($string, $length = -1);
}

class HproseStringStream extends HproseAbstractStream {
    protected $buffer;
    protected $pos;
    protected $mark;
    protected $length;
    public function __construct($string = '') {
        $this->buffer = $string;
        $this->pos = 0;
        $this->mark = -1;
        $this->length = strlen($string);
    }
    public function close() {
        $this->buffer = NULL;
        $this->pos = 0;
        $this->mark = -1;
        $this->length = 0;
    }
    public function length() {
        return $this->length;
    }
    public function getc() {
        return $this->buffer{$this->pos++};
    }
    public function read($length) {
        $s = substr($this->buffer, $this->pos, $length);
        $this->skip($length);
        return $s;
    }
    public function readuntil($tag) {
        $pos = strpos($this->buffer, $tag, $this->pos);
        if ($pos !== false) {
            $s = substr($this->buffer, $this->pos, $pos - $this->pos);
            $this->pos = $pos + strlen($tag);
        }
        else {
            $s = substr($this->buffer, $this->pos);
            $this->pos = $this->length;
        }
        return $s;
    }
    public function seek($offset, $whence = SEEK_SET) {
        switch ($whence) {
            case SEEK_SET:
                $this->pos = $offset;
                break;
            case SEEK_CUR:
                $this->pos += $offset;
                break;
            case SEEK_END:
                $this->pos = $this->length + $offset;
                break;
        }
        $this->mark = -1;
        return 0;
    }
    public function mark() {
        $this->mark = $this->pos;
    }
    public function unmark() {
        $this->mark = -1;
    }
    public function reset() {
        if ($this->mark != -1) {
            $this->pos = $this->mark;
        }
    }
    public function skip($n) {
        $this->pos += $n;
    }
    public function eof() {
        return ($this->pos >= $this->length);
    }
    public function write($string, $length = -1) {
        if ($length == -1) {
            $this->buffer .= $string;
            $length = strlen($string);
        }
        else {
            $this->buffer .= substr($string, 0, $length);
        }
        $this->length += $length;
    }
    public function toString() {
        return $this->buffer;
    }
}

class HproseFileStream extends HproseAbstractStream {
    protected $fp;
    protected $buf;
    protected $unmark;    
    protected $pos;
    protected $length;
    public function __construct($fp) {
        $this->fp = $fp;
        $this->buf = "";
        $this->unmark = true;
        $this->pos = -1;
        $this->length = 0;
    }
    public function close() {
        return fclose($this->fp);
    }
    public function getc() {
        if ($this->pos == -1) {
            return fgetc($this->fp);
        }
        else if ($this->pos < $this->length) {
            return $this->buf{$this->pos++};
        }
        else if ($this->unmark) {
            $this->buf = "";        
            $this->pos = -1;
            $this->length = 0;
            return fgetc($this->fp);            
        }
        else if (($c = fgetc($this->fp)) !== false) {
            $this->buf .= $c;
            $this->pos++;
            $this->length++;
        }
        return $c;
    }
    public function read($length) {
        if ($this->pos == -1) {
            return fread($this->fp, $length);
        }
        else if ($this->pos < $this->length) {
            $len = $this->length - $this->pos;
            if ($len < $length) {
                $s = fread($this->fp, $length - $len);
                $this->buf .= $s;
                $this->length += strlen($s);
            }
            $s = substr($this->buf, $this->pos, $length);
            $this->pos += strlen($s);
        }
        else if ($this->unmark) {
            $this->buf = "";        
            $this->pos = -1;
            $this->length = 0;
            return fread($this->fp, $length);           
        }
        else if (($s = fread($this->fp, $length)) !== "") {
            $this->buf .= $s;
            $len = strlen($s);
            $this->pos += $len;
            $this->length += $len;
        }
        return $s;
    }
    public function readuntil($char) {
        $s = '';
        while ((($c = $this->getc()) != $char) && $c !== false) $s .= $c;
        return $s;
    }
    public function seek($offset, $whence = SEEK_SET) {
        if (fseek($this->fp, $offset, $whence) == 0) {
            $this->buf = "";
            $this->unmark = true;
            $this->pos = -1;
            $this->length = 0;
            return 0;
        }
        return -1;
    }
    public function mark() {
        $this->unmark = false;
        if ($this->pos == -1) {
            $this->buf = "";
            $this->pos = 0;
            $this->length = 0;
        }
        else if ($this->pos > 0) {
            $this->buf = substr($this->buf, $this->pos);
            $this->length -= $this->pos;
            $this->pos = 0;
        }
    }
    public function unmark() {
        $this->unmark = true;
    }
    public function reset() {
        $this->pos = 0;
    }
    public function skip($n) {
        $this->read($n);
    }
    public function eof() {
        if (($this->pos != -1) && ($this->pos < $this->length)) return false;
        return feof($this->fp);
    }
    public function write($string, $length = -1) {
        if ($length == -1) $length = strlen($string);
        return fwrite($this->fp, $string, $length);
    }
}

class HproseProcStream extends HproseAbstractStream {
    protected $process;
    protected $pipes;
    protected $buf;
    protected $unmark;    
    protected $pos;
    protected $length;
    public function __construct($process, $pipes) {
        $this->process = $process;
        $this->pipes = $pipes;
        $this->buf = "";
        $this->unmark = true;
        $this->pos = -1;
        $this->length = 0;        
    }
    public function close() {
        fclose($this->pipes[0]);
        fclose($this->pipes[1]);
        proc_close($this->process);
    }
    public function getc() {
        if ($this->pos == -1) {
            return fgetc($this->pipes[1]);
        }
        else if ($this->pos < $this->length) {
            return $this->buf{$this->pos++};
        }
        else if ($this->unmark) {
            $this->buf = "";        
            $this->pos = -1;
            $this->length = 0;
            return fgetc($this->pipes[1]);
        }
        else if (($c = fgetc($this->pipes[1])) !== false) {
            $this->buf .= $c;
            $this->pos++;
            $this->length++;
        }
        return $c;
    }
    public function read($length) {
        if ($this->pos == -1) {
            return fread($this->pipes[1], $length);
        }
        else if ($this->pos < $this->length) {
            $len = $this->length - $this->pos;
            if ($len < $length) {
                $s = fread($this->pipes[1], $length - $len);
                $this->buf .= $s;
                $this->length += strlen($s);
            }
            $s = substr($this->buf, $this->pos, $length);
            $this->pos += strlen($s);
        }
        else if ($this->unmark) {
            $this->buf = "";        
            $this->pos = -1;
            $this->length = 0;
            return fread($this->pipes[1], $length);           
        }
        else if (($s = fread($this->pipes[1], $length)) !== "") {
            $this->buf .= $s;
            $len = strlen($s);
            $this->pos += $len;
            $this->length += $len;
        }
        return $s;
    }
    public function readuntil($char) {
        $s = '';
        while ((($c = $this->getc()) != $char) && $c !== false) $s .= $c;
        return $s;
    }
    public function seek($offset, $whence = SEEK_SET) {
        if (fseek($this->pipes[1], $offset, $whence) == 0) {
            $this->buf = "";
            $this->unmark = true;
            $this->pos = -1;
            $this->length = 0;
            return 0;
        }
        return -1;
    }
    public function mark() {
        $this->unmark = false;
        if ($this->pos == -1) {
            $this->buf = "";
            $this->pos = 0;
            $this->length = 0;
        }
        else if ($this->pos > 0) {
            $this->buf = substr($this->buf, $this->pos);
            $this->length -= $this->pos;
            $this->pos = 0;
        }
    }
    public function unmark() {
        $this->unmark = true;
    }
    public function reset() {
        $this->pos = 0;
    }
    public function skip($n) {
        $this->read($n);
    }
    public function eof() {
        if (($this->pos != -1) && ($this->pos < $this->length)) return false;
        return feof($this->pipes[1]);
    }
    public function write($string, $length = -1) {
        if ($length == -1) $length = strlen($string);
        return fwrite($this->pipes[0], $string, $length);
    }
}

class HproseTags {
    /* Serialize Tags */
    const TagInteger = 'i';
    const TagLong = 'l';
    const TagDouble = 'd';
    const TagNull = 'n';
    const TagEmpty = 'e';
    const TagTrue = 't';
    const TagFalse = 'f';
    const TagNaN = 'N';
    const TagInfinity = 'I';
    const TagDate = 'D';
    const TagTime = 'T';
    const TagUTC = 'Z';
    const TagBytes = 'b';
    const TagUTF8Char = 'u';
    const TagString = 's';
    const TagGuid = 'g';
    const TagList = 'a';
    const TagMap = 'm';
    const TagClass = 'c';
    const TagObject = 'o';
    const TagRef = 'r';
    /* Serialize Marks */
    const TagPos = '+';
    const TagNeg = '-';
    const TagSemicolon = ';';
    const TagOpenbrace = '{';
    const TagClosebrace = '}';
    const TagQuote = '"';
    const TagPoint = '.';
    /* Protocol Tags */
    const TagFunctions = 'F';
    const TagCall = 'C';
    const TagResult = 'R';
    const TagArgument = 'A';
    const TagError = 'E';
    const TagEnd = 'z';
}

class HproseClassManager {
    private static $classCache1 = array();
    private static $classCache2 = array();
    public static function register($class, $alias) {
        self::$classCache1[$alias] = $class;
        self::$classCache2[$class] = $alias;        
    }
    public static function getClassAlias($class) {
        if (array_key_exists($class, self::$classCache2)) {
            return self::$classCache2[$class];
        }
        return $class;
    }
    public static function getClass($alias) {
        if (array_key_exists($alias, self::$classCache1)) {
            return self::$classCache1[$alias];
        }
        if (!class_exists($alias)) eval("class " . $alias . " { }");
        return $alias;
    }
}

class HproseReader {
    public $stream;
    private $classref;
    private $ref;
    function __construct(&$stream) {
        $this->stream = &$stream;
        $this->classref = array();
        $this->ref = array();
    }
    public function &unserialize($tag = NULL) {
        if (is_null($tag)) {
            $tag = $this->stream->getc();
        }
        $result = NULL;
        switch ($tag) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                $result = (int)$tag; break;
            case HproseTags::TagInteger: $result = $this->readInteger(false); break;
            case HproseTags::TagLong: $result = $this->readLong(false); break;
            case HproseTags::TagDouble: $result = $this->readDouble(false); break;
            case HproseTags::TagNull: break;
            case HproseTags::TagEmpty: $result = ''; break;
            case HproseTags::TagTrue: $result = true; break;
            case HproseTags::TagFalse: $result = false; break;
            case HproseTags::TagNaN: $result = log(-1); break;
            case HproseTags::TagInfinity: $result = $this->readInfinity(false); break;
            case HproseTags::TagDate: $result = &$this->readDate(false); break;
            case HproseTags::TagTime: $result = &$this->readTime(false); break;
            case HproseTags::TagBytes: $result = $this->readBytes(false); break;
            case HproseTags::TagUTF8Char: $result = $this->readUTF8Char(false); break;            
            case HproseTags::TagString: $result = $this->readString(false); break;
            case HproseTags::TagGuid: $result = $this->readGuid(false); break;
            case HproseTags::TagList: $result = &$this->readList(false); break;
            case HproseTags::TagMap: $result = &$this->readMap(false); break;
            case HproseTags::TagClass: $this->readClass(); $result = &$this->unserialize(); break;
            case HproseTags::TagObject: $result = &$this->readObject(false); break;
            case HproseTags::TagRef:
                $r = &$this->readRef();
                if (gettype($r) == 'string') $result = $r;
                else $result = &$r;
                break;
            case HproseTags::TagError: throw new HproseException($this->readString());
            case false: throw new HproseException('No byte found in stream');
            default: throw new HproseException("Unexpected serialize tag '$tag' in stream");
        }
        return $result;
    }
    public function checkTag($expectTag, $tag = NULL) {
        if (is_null($tag)) $tag = $this->stream->getc();
        if ($tag != $expectTag) {
            throw new HproseException("Tag '$expectTag' expected, but '$tag' found in stream");
        }
    }
    public function checkTags($expectTags, $tag = NULL) {
        if (is_null($tag)) $tag = $this->stream->getc();
        if (!in_array($tag, $expectTags)) {
            $expectTags = implode('', $expectTags);
            throw new HproseException("Tag '$expectTags' expected, but '$tag' found in stream");
        }
        return $tag;
    }
    public function readInteger($includeTag = true) {
        if ($includeTag) {
            $tag = $this->stream->getc();
            if (($tag >= '0') && ($tag <= '9')) {
                return (int)$tag;
            }
            $this->checkTag(HproseTags::TagInteger, $tag);
        }
        $s = $this->stream->readuntil(HproseTags::TagSemicolon);
        return (int)$s;
    }
    public function readLong($includeTag = true) {
        if ($includeTag) {
            $tag = $this->stream->getc();
            if (($tag >= '0') && ($tag <= '9')) {
                return $tag;
            }
            $this->checkTag(HproseTags::TagLong, $tag);
        }
        $s = $this->stream->readuntil(HproseTags::TagSemicolon);
        return $s;
    }
    public function readDouble($includeTag = true) {
        if ($includeTag) {
            $tag = $this->stream->getc();
            if (($tag >= '0') && ($tag <= '9')) {
                return (double)$tag;
            }
            $this->checkTag(HproseTags::TagDouble, $tag);
        }
        $s = $this->stream->readuntil(HproseTags::TagSemicolon);
        return (double)$s;
    }
    public function readNaN() {
        $this->checkTag(HproseTags::TagNaN);
        return log(-1);
    }
    public function readInfinity($includeTag = true) {
        if ($includeTag) $this->checkTag(HproseTags::TagInfinity);
        return (($this->stream->getc() == HproseTags::TagNeg) ? log(0) : -log(0));
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
        $tag = $this->checkTags(array(HproseTags::TagTrue, HproseTags::TagFalse));
        return ($tag == HproseTags::TagTrue);
    }
    public function &readDate($includeTag = true) {
        if ($includeTag) {
            $tag = $this->checkTags(array(HproseTags::TagDate, HproseTags::TagRef));
            if ($tag == HproseTags::TagRef) return $this->readRef();
        }
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
        $this->ref[] = &$date;
        return $date;
    }
    public function &readTime($includeTag = true) {
        if ($includeTag) {
            $tag = $this->checkTags(array(HproseTags::TagTime, HproseTags::TagRef));
            if ($tag == HproseTags::TagRef) return $this->readRef();
        }
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
        $this->ref[] = &$time;
        return $time;
    }
    public function readBytes($includeTag = true) {
        if ($includeTag) {
            $tag = $this->checkTags(array(HproseTags::TagBytes, HproseTags::TagRef));
            if ($tag == HproseTags::TagRef) return $this->readRef();
        }
        $s = $this->stream->read((int)$this->stream->readuntil(HproseTags::TagQuote));
        $this->stream->skip(1);
        $this->ref[] = $s;
        return $s;
    }
    public function readUTF8Char($includeTag = true) {
        if ($includeTag) $this->checkTag(HproseTags::TagUTF8Char);
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
    public function readString($includeTag = true, $includeRef = true) {
        if ($includeTag) {
            $tag = $this->checkTags(array(HproseTags::TagString, HproseTags::TagRef));
            if ($tag == HproseTags::TagRef) return $this->readRef();
        }
        $len = (int)$this->stream->readuntil(HproseTags::TagQuote);
        $this->stream->mark();
        $utf8len = 0;
        for ($i = 0; $i < $len; $i++) {
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
                    $i++;
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
        if ($includeRef) $this->ref[] = $s;
        return $s;
    }
    public function readGuid($includeTag = true) {
        if ($includeTag) {
            $tag = $this->checkTags(array(HproseTags::TagGuid, HproseTags::TagRef));
            if ($tag == HproseTags::TagRef) return $this->readRef();
        }
        $this->stream->skip(1);
        $s = $this->stream->read(36);
        $this->stream->skip(1);
        $this->ref[] = $s;
        return $s;
    }
    public function &readList($includeTag = true) {
        if ($includeTag) {
            $tag = $this->checkTags(array(HproseTags::TagList, HproseTags::TagRef));
            if ($tag == HproseTags::TagRef) return $this->readRef();
        }
        $list = array();
        $this->ref[] = &$list;
        $count = (int)$this->stream->readuntil(HproseTags::TagOpenbrace);
        for ($i = 0; $i < $count; $i++) {
            $list[] = &$this->unserialize();
        }
        $this->stream->skip(1);
        return $list;
    }
    public function &readMap($includeTag = true) {
        if ($includeTag) {
            $tag = $this->checkTags(array(HproseTags::TagMap, HproseTags::TagRef));
            if ($tag == HproseTags::TagRef) return $this->readRef();
        }
        $map = array();
        $this->ref[] = &$map;
        $count = (int)$this->stream->readuntil(HproseTags::TagOpenbrace);
        for ($i = 0; $i < $count; $i++) {
            $key = &$this->unserialize();
            $value = &$this->unserialize();
            $map[$key] = &$value;
        }
        $this->stream->skip(1);
        return $map;
    }
    public function &readObject($includeTag = true) {
        if ($includeTag) {
            $tag = $this->checkTags(array(HproseTags::TagClass, HproseTags::TagObject, HproseTags::TagRef));
            if ($tag == HproseTags::TagRef) return $this->readRef();
            if ($tag == HproseTags::TagClass) {
                $this->readClass();
                return $this->readObject();
            }
        }
        list($classname, $count, $fields) = $this->classref[(int)$this->stream->readuntil(HproseTags::TagOpenbrace)];
        $object = new $classname;
        $this->ref[] = &$object;
        for ($i = 0; $i < $count; $i++) {
            $object->$fields[$i] = &$this->unserialize();
        }
        $this->stream->skip(1);
        return $object;
    }
    private function readClass() {
        $classname = HproseClassManager::getClass($this->readString(false, false));
        $count = (int)$this->stream->readuntil(HproseTags::TagOpenbrace);
        $fields = array();
        for ($i = 0; $i < $count; $i++) {
            $fields[] = $this->readString();
        }
        $this->stream->skip(1);
        $this->classref[] = array($classname, $count, $fields);
    }
    private function &readRef() {
        return $this->ref[(int)$this->stream->readuntil(HproseTags::TagSemicolon)];
    }
    public function reset() {
        $this->classref = array();
        $this->ref = array();
    }

    public function readRaw($ostream = NULL, $tag = NULL) {
        if (is_null($ostream)) {
            $ostream = new HproseStringStream();
        }
        if (is_null($tag)) {
            $tag = $this->stream->getc();
        }
        switch ($tag) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            case HproseTags::TagNull:
            case HproseTags::TagEmpty:
            case HproseTags::TagTrue:
            case HproseTags::TagFalse:
            case HproseTags::TagNaN:
                $ostream->write($tag);
                break;
            case HproseTags::TagInfinity:
                $ostream->write($tag);
                $ostream->write($this->stream->getc());
                break;
            case HproseTags::TagInteger:
            case HproseTags::TagLong:
            case HproseTags::TagDouble:
            case HproseTags::TagRef:
                $this->readNumberRaw($ostream, $tag);
                break;
            case HproseTags::TagDate:
            case HproseTags::TagTime:
                $this->readDateTimeRaw($ostream, $tag);
                break;
            case HproseTags::TagUTF8Char:
                $this->readUTF8CharRaw($ostream, $tag);
                break;
            case HproseTags::TagBytes:
                $this->readBytesRaw($ostream, $tag);
                break;
            case HproseTags::TagString:
                $this->readStringRaw($ostream, $tag);
                break;
            case HproseTags::TagGuid:
                $this->readGuidRaw($ostream, $tag);
                break;
            case HproseTags::TagList:
            case HproseTags::TagMap:
            case HproseTags::TagObject:
                $this->readComplexRaw($ostream, $tag);
                break;
            case HproseTags::TagClass:
                $this->readComplexRaw($ostream, $tag);
                $this->readRaw($ostream);
                break;
            case HproseTags::TagError:
                $ostream->write($tag);
                $this->readRaw($ostream);
                break;
            case false:
                throw new HproseException("No byte found in stream");
            default:
                throw new HproseException("Unexpected serialize tag '" + $tag + "' in stream");
        }
    	return $ostream;
    }

    private function readNumberRaw($ostream, $tag) {
        $s = $tag .
             $this->stream->readuntil(HproseTags::TagSemicolon) .
             HproseTags::TagSemicolon;
        $ostream->write($s);
    }

    private function readDateTimeRaw($ostream, $tag) {
        $s = $tag;
        do {
            $tag = $this->stream->getc();
            $s .= $tag;
        } while ($tag != HproseTags::TagSemicolon &&
                 $tag != HproseTags::TagUTC);
        $ostream->write($s);
    }

    private function readUTF8CharRaw($ostream, $tag) {
        $s = $tag;
        $tag = $this->stream->getc();
        $s .= $tag;
        $a = ord($tag);
        if (($a & 0xE0) == 0xC0) {
            $s .= $this->stream->getc();
        }
        elseif (($a & 0xF0) == 0xE0) {
            $s .= $this->stream->read(2);
        }
        elseif ($a > 0x7F) {
            throw new HproseException("bad utf-8 encoding");
        }
        $ostream->write($s);
    }

    private function readBytesRaw($ostream, $tag) {
        $len = $this->stream->readuntil(HproseTags::TagQuote);
        $s = $tag . $len . HproseTags::TagQuote . $this->stream->read((int)$len) . HproseTags::TagQuote;
        $this->stream->skip(1);
        $ostream->write($s);
    }

    private function readStringRaw($ostream, $tag) {
        $len = $this->stream->readuntil(HproseTags::TagQuote);
        $s = $tag . $len . HproseTags::TagQuote;
        $len = (int)$len;
        $this->stream->mark();
        $utf8len = 0;
        for ($i = 0; $i < $len; $i++) {
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
                    $i++;
                    break;
                }
                default: {
                    throw new HproseException('bad utf-8 encoding');
                }
            }
        }
        $this->stream->reset();
        $this->stream->unmark();
        $s .= $this->stream->read($utf8len) . HproseTags::TagQuote;
        $this->stream->skip(1);
        $ostream->write($s);
    }

    private function readGuidRaw($ostream, $tag) {
        $s = $tag . $this->stream->read(38);
        $ostream->write($s);
    }

    private function readComplexRaw($ostream, $tag) {
        $s = $tag .
             $this->stream->readuntil(HproseTags::TagOpenbrace) .
             HproseTags::TagOpenbrace;
        $ostream->write($s);
        while (($tag = $this->stream->getc()) != HproseTags::TagClosebrace) {
            $this->readRaw($ostream, $tag);
        }
        $ostream->write($tag);
    }
}

class HproseWriter {
    public $stream;
    private $classref;
    private $ref;
    function __construct(&$stream) {
        $this->stream = &$stream;
        $this->classref = array();
        $this->ref = array();
    }
    private function ref_equals(&$a, &$b) {
        if (is_array($a) && is_array($b)) {
            return (serialize($a) == serialize($b));
        }
        return ($a === $b);
    }
    private function ref_search(&$value) {
        foreach ($this->ref as $i => &$ref) {
            if ($this->ref_equals($value, $ref)) return $i;
        }
        return false;
    }
    public function serialize(&$variable) {
        switch(gettype($variable)) {
            case 'NULL':
                $this->writeNull();
                break;
            case 'boolean':
                $this->writeBoolean($variable);
                break;
            case 'integer':
                $this->writeInteger($variable);
                break;
            case 'double':
                $this->writeDouble($variable);
                break;
            case 'string':
                if ($variable == '') {
                    $this->writeEmpty();
                }
                elseif ((strlen($variable) < 4) && (ustrlen($variable) == 1)) {
                    $this->writeUTF8Char($variable);
                }
                elseif (($ref = $this->ref_search($variable)) !== false) {
                    $this->writeRef($ref);
                }
                elseif (is_utf8($variable)) {
                    $this->writeString($variable, false);
                }
                else {
                    $this->writeBytes($variable, false);
                }
                break;
            case 'array':
                if (($ref = $this->ref_search($variable)) !== false) {
                    $this->writeRef($ref);
                }
                elseif (is_list($variable)) {
                    $this->writeList($variable, false);
                }
                else {
                    $this->writeMap($variable, false);
                }
                break;
            case 'object':
                if (($ref = $this->ref_search($variable)) !== false) {
                    $this->writeRef($ref);
                }
                elseif ($variable instanceof stdClass) {
                    $this->writeMap($variable, false);
                }
                elseif (($variable instanceof HproseDate) || ($variable instanceof HproseDateTime)) {
                    $this->writeDate($variable, false);
                }
                elseif ($variable instanceof HproseTime) {
                    $this->writeTime($variable, false);
                }
                else {
                    $this->writeObject($variable, false);
                }
                break;
            default:
                throw new HproseException('Not support to serialize this data');
        }
    }
    public function writeInteger($integer) {
        if ($integer >= 0 && $integer <= 9) {
            $this->stream->write((string)$integer);
        }
        else {
            $this->stream->write(HproseTags::TagInteger . $integer . HproseTags::TagSemicolon);
        }
    }
    public function writeLong($long) {
        if ($long >= '0' && $long <= '9') {
            $this->stream->write($long);
        }
        else {
            $this->stream->write(HproseTags::TagLong . $long . HproseTags::TagSemicolon);
        }
    }
    public function writeDouble($double) {
        if (is_nan($double)) {
            $this->writeNaN();
        }
        elseif (is_infinite($double)) {
            $this->writeInfinity($double > 0);
        }
        else {
            $this->stream->write(HproseTags::TagDouble . $double . HproseTags::TagSemicolon);
        }
    }
    public function writeNaN() {
        $this->stream->write(HproseTags::TagNaN);
    }
    public function writeInfinity($positive = true) {
        $this->stream->write(HproseTags::TagInfinity . ($positive ? HproseTags::TagPos : HproseTags::TagNeg));
    }
    public function writeNull() {
        $this->stream->write(HproseTags::TagNull);
    }
    public function writeEmpty() {
        $this->stream->write(HproseTags::TagEmpty);
    }
    public function writeBoolean($bool) {
        $this->stream->write($bool ? HproseTags::TagTrue : HproseTags::TagFalse);
    }
    public function writeDate(&$date, $checkRef = true) {
        if ($checkRef && (($ref = $this->ref_search($date)) !== false)) {
            $this->writeRef($ref);
        }
        else {
            $this->ref[] = &$date;
            if ($date->utc) {
                $this->stream->write(HproseTags::TagDate . $date->toString(false));
            }
            else {
                $this->stream->write(HproseTags::TagDate . $date->toString(false) . HproseTags::TagSemicolon);
            }
        }
    }
    public function writeTime(&$time, $checkRef = true) {
        if ($checkRef && (($ref = $this->ref_search($time)) !== false)) {
            $this->writeRef($ref);
        }
        else {
            $this->ref[] = &$time;
            if ($time->utc) {
                $this->stream->write(HproseTags::TagTime . $time->toString(false));
            }
            else {
                $this->stream->write(HproseTags::TagTime . $time->toString(false) . HproseTags::TagSemicolon);
            }
        }
    }
    public function writeBytes(&$string, $checkRef = true) {
        if ($checkRef && (($ref = $this->ref_search($string)) !== false)) {
            $this->writeRef($ref);
        }
        else {
            $this->ref[] = $string;
            $len = strlen($string);
            $this->stream->write(HproseTags::TagBytes);
            if ($len > 0) $this->stream->write($len);
            $this->stream->write(HproseTags::TagQuote . $string . HproseTags::TagQuote);
        }
    }
    public function writeUTF8Char(&$string) {
        $this->stream->write(HproseTags::TagUTF8Char . $string);
    }
    public function writeString(&$string, $checkRef = true) {
        if ($checkRef && (($ref = $this->ref_search($string)) !== false)) {
            $this->writeRef($ref);
        }
        else {
            $this->ref[] = $string;
            $len = ustrlen($string);
            $this->stream->write(HproseTags::TagString);
            if ($len > 0) $this->stream->write($len);
            $this->stream->write(HproseTags::TagQuote . $string . HproseTags::TagQuote);
        }
    }
    public function writeList(&$list, $checkRef = true) {
        if ($checkRef && (($ref = $this->ref_search($list)) !== false)) {
            $this->writeRef($ref);
        }
        else {
            $this->ref[] = &$list;
            $count = count($list);
            $this->stream->write(HproseTags::TagList);
            if ($count > 0) $this->stream->write($count); 
            $this->stream->write(HproseTags::TagOpenbrace);
            for ($i = 0; $i < $count; $i++) {
                $this->serialize($list[$i]);
            }
            $this->stream->write(HproseTags::TagClosebrace);
        }
    }
    public function writeMap(&$map, $checkRef = true) {
        if ($checkRef && (($ref = $this->ref_search($map)) !== false)) {
            $this->writeRef($ref);
        }
        else {
            $this->ref[] = &$map;
            $count = count($map);
            $this->stream->write(HproseTags::TagMap);
            if ($count > 0) $this->stream->write($count); 
            $this->stream->write(HproseTags::TagOpenbrace);
            foreach ($map as $key => &$value) {
                $this->serialize($key);
                $this->serialize($value);
            }
            $this->stream->write(HproseTags::TagClosebrace);
        }
    }
    public function writeObject(&$object, $checkRef = true) {
        if ($checkRef && (($ref = $this->ref_search($object)) !== false)) {
            $this->writeRef($ref);
        }
        else {
            $classname = HproseClassManager::getClassAlias(get_class($object));
            $array = (array)$object;
            $fields = array_keys($array);
            $class = array($classname, $fields);
            if (($classref = array_search($class, $this->classref, true)) === false) {
                $classref = $this->writeClass($class);
            }
            $this->ref[] = &$object;
            $count = count($fields);
            $this->stream->write(HproseTags::TagObject . $classref . HproseTags::TagOpenbrace);
            for ($i = 0; $i < $count; $i++) {
                $this->serialize($array[$fields[$i]]);
            }
            $this->stream->write(HproseTags::TagClosebrace);
        }
    }
    private function writeClass(&$class) {
        list($classname, $fields) = $class;
        $count = count($fields);
        $len = ustrlen($classname);
        $this->stream->write(HproseTags::TagClass . $len .
                             HproseTags::TagQuote . $classname . HproseTags::TagQuote);
        if ($count > 0) $this->stream->write($count); 
        $this->stream->write(HproseTags::TagOpenbrace);
        for ($i = 0; $i < $count; $i++) {
            $field = $fields[$i];
            if ($field{0} == "\0") {
                $field = substr($field, strpos($field, "\0", 1) + 1);
            }
            $this->writeString($field);
        }
        $this->stream->write(HproseTags::TagClosebrace);
        $classref = count($this->classref);
        $this->classref[] = &$class;
        return $classref;
    }
    private function writeRef($ref) {
        $this->stream->write(HproseTags::TagRef . $ref . HproseTags::TagSemicolon);
    }
    public function reset() {
        $this->classref = array();
        $this->ref = array();
    }
}

class HproseFormatter {
    public static function serialize($variable) {
        $stream = new HproseStringStream();
        $hproseWriter = new HproseWriter($stream);
        $hproseWriter->serialize($variable);
        return $stream->toString();
    }
    public static function unserialize($variable_representation) {
        $stream = new HproseStringStream($variable_representation);
        $hproseReader = new HproseReader($stream);
        return $hproseReader->unserialize();
    }
}
?>
