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
 * HproseReader.php                                       *
 *                                                        *
 * hprose reader class for php5.                          *
 *                                                        *
 * LastModified: Jan 2, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require_once('HproseSimpleReader.php');

class HproseReader extends HproseSimpleReader {
    private $ref;
    function __construct(&$stream) {
        parent::__construct($stream);
        $this->ref = array();
    }
    public function readDateWithoutTag() {
        $date = parent::readDateWithoutTag();
        $this->ref[] = $date;
        return $date;
    }
    public function readTimeWithoutTag() {
        $time = parent::readTimeWithoutTag();
        $this->ref[] = $time;
        return $time;
    }
    public function readBytesWithoutTag() {
        $bytes = parent::readBytesWithoutTag();
        $this->ref[] = $bytes;
        return $bytes;
    }
    public function readStringWithoutTag() {
        $str = parent::readStringWithoutTag();
        $this->ref[] = $str;
        return $str;
    }
    public function readGuidWithoutTag() {
        $guid = parent::readGuidWithoutTag();
        $this->ref[] = $guid;
        return $guid;
    }
    public function &readListWithoutTag() {
        $list = &$this->readListBegin();
        $this->ref[] = &$list;
        return $this->readListEnd($list);
    }
    public function &readMapWithoutTag() {
        $map = &$this->readMapBegin();
        $this->ref[] = &$map;
        return $this->readMapEnd($map);
    }
    public function readObjectWithoutTag() {
        list($object, $fields) = $this->readObjectBegin();
        $this->ref[] = $object;
        return $this->readObjectEnd($object, $fields);
    }
    protected function &readRef() {
        $ref = &$this->ref[(int)$this->stream->readuntil(HproseTags::TagSemicolon)];
        if (gettype($ref) == 'array') {
            $result = &$ref;
        }
        else {
            $result = $ref;
        }
        return $result;
    }
    public function reset() {
        parent::reset();
        $this->ref = array();
    }
}
?>