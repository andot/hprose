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
 * HproseSimpleWriter.php                                 *
 *                                                        *
 * hprose simple writer class for php5.                   *
 *                                                        *
 * LastModified: Jan 2, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require_once('HproseCommon.php');
require_once('HproseTags.php');
require_once('HproseClassManager.php');

class HproseSimpleWriter {
    public $stream;
    private $classref;
    private $fieldsref;
    function __construct(&$stream) {
        $this->stream = &$stream;
        $this->classref = array();
        $this->fieldsref = array();
    }
    public function serialize(&$var) {
        if ((!isset($var)) || ($var === NULL)) {
            $this->writeNull();
        }
        elseif (is_scalar($var)) {
            if (is_int($var)) {
                if ($var >= 0 && $var <= 9) {
                    $this->stream->write((string)$var);
                }
                else {
                    $this->writeInteger($var);
                }
            }
            elseif (is_bool($var)) {
                $this->writeBoolean($var);
            }
            elseif (is_float($var)) {
                $this->writeDouble($var);
            }
            elseif (is_string($var)) {
                if ($var === '') {
                    $this->writeEmpty();
                }
                elseif ((strlen($var) < 4) && is_utf8($var) && (ustrlen($var) == 1)) {
                    $this->writeUTF8Char($var);
                }
                elseif (is_utf8($var)) {
                    $this->writeStringWithRef($var);
                }
                else {
                    $this->writeBytesWithRef($var);
                }
            }
        }
        elseif (is_array($var)) {
            if (is_list($var)) {
                $this->writeListWithRef($var);
            }
            else {
               $this->writeMapWithRef($var);
            }
        }
        elseif (is_object($var)) {
            if ($var instanceof stdClass) {
                $this->writeStdObjectWithRef($var);
            }
            elseif (($var instanceof HproseDate) || ($var instanceof HproseDateTime)) {
                $this->writeDateWithRef($var);
            }
            elseif ($var instanceof HproseTime) {
                $this->writeTimeWithRef($var);
            }
            else {
                $this->writeObjectWithRef($var);
            }
        }
        else {
            throw new HproseException('Not support to serialize this data');
        }
    }
    public function writeInteger($integer) {
        $this->stream->write(HproseTags::TagInteger . $integer . HproseTags::TagSemicolon);
    }
    public function writeLong($long) {
        $this->stream->write(HproseTags::TagLong . $long . HproseTags::TagSemicolon);
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
    public function writeDate($date) {
        if ($date->utc) {
            $this->stream->write(HproseTags::TagDate . $date->toString(false));
        }
        else {
            $this->stream->write(HproseTags::TagDate . $date->toString(false) . HproseTags::TagSemicolon);
        }
    }
    public function writeDateWithRef($date) {
        if (!$this->writeRef($date)) $this->writeDate($date);
    }
    public function writeTime($time) {
        if ($time->utc) {
            $this->stream->write(HproseTags::TagTime . $time->toString(false));
        }
        else {
            $this->stream->write(HproseTags::TagTime . $time->toString(false) . HproseTags::TagSemicolon);
        }
    }
    public function writeTimeWithRef($time) {
        if (!$this->writeRef($time)) $this->writeTime($time);
    }
    public function writeBytes($bytes) {
        $len = strlen($bytes);
        $this->stream->write(HproseTags::TagBytes);
        if ($len > 0) $this->stream->write((string)$len);
        $this->stream->write(HproseTags::TagQuote . $bytes . HproseTags::TagQuote);
    }
    public function writeBytesWithRef($bytes) {
        if (!$this->writeRef($bytes)) $this->writeBytes($bytes);
    }
    public function writeUTF8Char($char) {
        $this->stream->write(HproseTags::TagUTF8Char . $char);
    }
    public function writeString($str) {
        $len = ustrlen($str);
        $this->stream->write(HproseTags::TagString);
        if ($len > 0) $this->stream->write((string)$len);
        $this->stream->write(HproseTags::TagQuote . $str . HproseTags::TagQuote);
    }
    public function writeStringWithRef($str) {
        if (!$this->writeRef($str)) $this->writeString($str);
    }
    public function writeList(&$list) {
        $count = count($list);
        $this->stream->write(HproseTags::TagList);
        if ($count > 0) $this->stream->write((string)$count);
        $this->stream->write(HproseTags::TagOpenbrace);
        for ($i = 0; $i < $count; ++$i) {
            $this->serialize($list[$i]);
        }
        $this->stream->write(HproseTags::TagClosebrace);
    }
    public function writeListWithRef(&$list) {
        if (!$this->writeRef($list)) $this->writeList($list);
    }
    public function writeMap(&$map) {
        $count = count($map);
        $this->stream->write(HproseTags::TagMap);
        if ($count > 0) $this->stream->write((string)$count);
        $this->stream->write(HproseTags::TagOpenbrace);
        foreach ($map as $key => &$value) {
            $this->serialize($key);
            $this->serialize($value);
        }
        $this->stream->write(HproseTags::TagClosebrace);
    }
    public function writeMapWithRef(&$map) {
        if (!$this->writeRef($map)) $this->writeMap($map);
    }
    public function writeStdObject($obj) {
        $map = (array)$obj;
        self::writeMap($map);
    }
    public function writeStdObjectWithRef($obj) {
        if (!$this->writeRef($obj)) $this->writeStdObject($obj);
    }
    protected function writeObjectBegin($obj) {
        $class = get_class($obj);
        $alias = HproseClassManager::getClassAlias($class);
        $fields = array_keys((array)$obj);
        if (array_key_exists($alias, $this->classref)) {
            $index = $this->classref[$alias];
        }
        else {
            $index = $this->writeClass($alias, $fields);
        }
        return $index;
    }
    protected function writeObjectEnd($obj, $index) {
            $fields = $this->fieldsref[$index];
            $count = count($fields);
            $this->stream->write(HproseTags::TagObject . $index . HproseTags::TagOpenbrace);
            $array = (array)$obj;
            for ($i = 0; $i < $count; ++$i) {
                $this->serialize($array[$fields[$i]]);
            }
            $this->stream->write(HproseTags::TagClosebrace);
    }
    public function writeObject($obj, $checkRef = false) {
        $this->writeObjectEnd($obj, $this->writeObjectBegin($obj));
    }
    public function writeObjectWithRef($obj) {
        if (!$this->writeRef($obj)) $this->writeObject($obj);
    }
    protected function writeClass($alias, $fields) {
        $len = ustrlen($alias);
        $this->stream->write(HproseTags::TagClass . $len .
                             HproseTags::TagQuote . $alias . HproseTags::TagQuote);
        $count = count($fields);
        if ($count > 0) $this->stream->write((string)$count);
        $this->stream->write(HproseTags::TagOpenbrace);
        for ($i = 0; $i < $count; ++$i) {
            $field = $fields[$i];
            if ($field{0} === "\0") {
                $field = substr($field, strpos($field, "\0", 1) + 1);
            }
            $this->writeString($field);
        }
        $this->stream->write(HproseTags::TagClosebrace);
        $index = count($this->fieldsref);
        $this->classref[$alias] = $index;
        $this->fieldsref[$index] = $fields;
        return $index;
    }
    protected function writeRef(&$obj) {
        return false;
    }
    public function reset() {
        $this->classref = array();
        $this->fieldsref = array();
    }
}

?>