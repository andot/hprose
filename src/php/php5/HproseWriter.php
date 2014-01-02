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
 * HproseWriter.php                                       *
 *                                                        *
 * hprose writer class for php5.                          *
 *                                                        *
 * LastModified: Jan 2, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require_once('HproseSimpleWriter.php');

class HproseWriter extends HproseSimpleWriter {
    private $ref;
    private $arrayref;
    private $refcount;
    function __construct(&$stream) {
        parent::__construct($stream);
        $this->ref = array();
        $this->arrayref = array();
        $this->refcount = 0;
    }
    private function getKey(&$obj) {
        if (is_string($obj)) {
            $key = 's_' . $obj;
        }
        elseif (is_array($obj)) {
            if (($i = array_ref_search($obj, $this->arrayref)) === false) {
                $i = count($this->arrayref);
                $this->arrayref[$i] = &$obj;
            }
            $key = 'a_' . $i;
        }
        else {
            $key = 'o_' . spl_object_hash($obj);
        }
        return $key;
    }
    public function writeDate($date) {
        $this->ref[$this->getKey($date)] = $this->refcount++;
        parent::writeDate($date);
    }
    public function writeTime($time) {
        $this->ref[$this->getKey($time)] = $this->refcount++;
        parent::writeTime($time);
    }
    public function writeBytes($bytes) {
        $this->ref[$this->getKey($bytes)] = $this->refcount++;
        parent::writeBytes($bytes);
    }
    public function writeString($str) {
        $this->ref[$this->getKey($str)] = $this->refcount++;
        parent::writeString($str);
    }
    public function writeList(&$list) {
        $this->ref[$this->getKey($list)] = $this->refcount++;
        parent::writeList($list);
    }
    public function writeMap(&$map) {
        $this->ref[$this->getKey($map)] = $this->refcount++;
        parent::writeMap($map);
    }
    public function writeStdObject($obj) {
        $this->ref[$this->getKey($obj)] = $this->refcount++;
        parent::writeStdObject($obj);
    }
    public function writeObject($obj, $checkRef = false) {
        $index = $this->writeObjectBegin($obj);
        $this->ref[$this->getKey($obj)] = $this->refcount++;
        $this->writeObjectEnd($obj, $index);
    }
    protected function writeRef(&$obj) {
        $key = $this->getKey($obj);
        if (array_key_exists($key, $this->ref)) {
            $this->stream->write(HproseTags::TagRef . $this->ref[$key] . HproseTags::TagSemicolon);
            return true;
        }
        return false;
    }
    public function reset() {
        parent::reset();
        $this->ref = array();
        $this->arrayref = array();
        $this->refcount = 0;
    }
}

?>