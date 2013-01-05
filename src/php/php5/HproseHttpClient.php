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
 * HproseHttpClient.php                                   *
 *                                                        *
 * hprose http client library for php5.                   *
 *                                                        *
 * LastModified: Nov 28, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require_once('HproseCommon.php');
require_once('HproseIO.php');

class HproseHttpClient {
    private $url;
    private $host;
    private $path;
    private $secure;
    private $proxy;
    private $header;
    private $timeout;
    private $keepAlive;
    private $keepAliveTimeout;
    private $filter;
    private static $cookieManager = array();
    static function hproseKeepCookieInSession() {
        $_SESSION['HPROSE_COOKIE_MANAGER'] = self::$cookieManager;
    }
    public static function keepSession() {
        if (isset($_SESSION['HPROSE_COOKIE_MANAGER'])) {
            self::$cookieManager = $_SESSION['HPROSE_COOKIE_MANAGER'];
        }

        register_shutdown_function(array('HproseHttpClient', 'hproseKeepCookieInSession'));
    }
    private function setCookie($headers) {
        foreach ($headers as $header) {
            @list($name, $value) = explode(':', $header, 2);
            if (strtolower($name) == 'set-cookie' ||
                strtolower($name) == 'set-cookie2') {
                $cookies = explode(';', trim($value));
                $cookie = array();
                list($name, $value) = explode('=', trim($cookies[0]), 2);
                $cookie['name'] = $name;
                $cookie['value'] = $value;
                for ($i = 1; $i < count($cookies); $i++) {
                    list($name, $value) = explode('=', trim($cookies[$i]), 2);
                    $cookie[strtoupper($name)] = $value;
                }
                // Tomcat can return SetCookie2 with path wrapped in "
                if (isset($cookie['PATH'])) {
                    $cookie['PATH'] = trim($cookie['PATH'], '"');
                }
                else {
                    $cookie['PATH'] = '/';
                }
                if (isset($cookie['EXPIRES'])) {
                    $cookie['EXPIRES'] = strtotime($cookie['EXPIRES']);
                }
                if (isset($cookie['DOMAIN'])) {
                    $cookie['DOMAIN'] = strtolower($cookie['DOMAIN']);
                }
                else {
                    $cookie['DOMAIN'] = $this->host;
                }
                $cookie['SECURE'] = isset($cookie['SECURE']);
                if (!isset(self::$cookieManager[$cookie['DOMAIN']])) {
                    self::$cookieManager[$cookie['DOMAIN']] = array();
                }
                self::$cookieManager[$cookie['DOMAIN']][$cookie['name']] = $cookie;
            }
        }
    }
    private function getCookie() {
        $cookies = array();
        foreach (self::$cookieManager as $domain => $cookieList) {
            if (strpos($this->host, $domain) !== false) {
                $names = array();
                foreach ($cookieList as $cookie) {
                    if (isset($cookie['EXPIRES']) && (time() > $cookie['EXPIRES'])) {
                        $names[] = $cookie['name'];
                    }
                    else if (strpos($this->path, $cookie['PATH']) === 0) {
                        if ((($this->secure && $cookie['SECURE']) ||
                             !$cookie['SECURE']) && !is_null($cookie['value'])) {
                            $cookies[] = $cookie['name'] . '=' . $cookie['value'];
                        }
                    }
                }
                foreach ($names as $name) {
                    unset(self::$cookieManager[$domain][$name]);
                }
            }
        }
        if (count($cookies) > 0) {
            return "Cookie: " . implode('; ', $cookies) . "\r\n";
        }
        return '';
    }
    public function __construct($url = '') {
        $this->useService($url);
        $this->header = array('Content-type' => 'application/hprose');
        $this->filter = NULL;
    }
    public function useService($url = '', $namespace = '') {
        if ($url) {
            $this->url = $url;
            $url = parse_url($url);
            $this->secure = (strtolower($url['scheme']) == 'https');
            $this->host = strtolower($url['host']);
            $this->path = $url['path'];
            $this->timeout = 30000;
            $this->keepAlive = false;
            $this->keepAliveTimeout = 300;
        }
        return new HproseProxy($this, $namespace);
    }
    public function __errorHandler($errno, $errstr, $errfile, $errline) {
        throw new Exception($errstr, $errno);
    }
    public function invoke($functionName, &$arguments = array(), $byRef = false, $resultMode = HproseResultMode::Normal) {
        $stream = new HproseStringStream(HproseTags::TagCall);
        $hproseWriter = new HproseWriter($stream);
        $hproseWriter->writeString($functionName, false);
        if (count($arguments) > 0 || $byRef) {
            $hproseWriter->reset();
            $hproseWriter->writeList($arguments, false);
            if ($byRef) {
                $hproseWriter->writeBoolean(true);
            }
        }
        $stream->write(HproseTags::TagEnd);
        $request = $stream->toString();
        if ($this->filter) $request = $this->filter->outputFilter($request);
        $stream->close();
        $opts = array (
            'http' => array (
                'method' => 'POST',
                'header'=> $this->getCookie() .
                           "Content-Length: " . strlen($request) . "\r\n" .
                           ($this->keepAlive ?
                           "Connection: keep-alive\r\n" .
                           "Keep-Alive: " . $this->keepAliveTimeout . "\r\n" :
                           "Connection: close\r\n"),
                'content' => $request,
                'timeout' => $this->timeout / 1000.0,
            ),
        );
        foreach ($this->header as $name => $value) {
            $opts['http']['header'] .= "$name: $value\r\n";
        }
        if ($this->proxy) {
            $opts['http']['proxy'] = $this->proxy;
            $opts['http']['request_fulluri'] = true;
        }
        $context = stream_context_create($opts);
        set_error_handler(array(&$this, '__errorHandler'));
        $response = file_get_contents($this->url, false, $context);
        if ($this->filter) $response = $this->filter->inputFilter($response);
        restore_error_handler();
        $this->setCookie($http_response_header);
        if ($resultMode == HproseResultMode::RawWithEndTag) {
            return $response;
        }
        if ($resultMode == HproseResultMode::Raw) {
            return substr($response, 0, -1);
        }
        $stream = new HproseStringStream($response);
        $hproseReader = new HproseReader($stream);
        $result = NULL;
        $error = NULL;
        while (($tag = $hproseReader->checkTags(
            array(HproseTags::TagResult,
                  HproseTags::TagArgument,
                  HproseTags::TagError,
                  HproseTags::TagEnd))) !== HproseTags::TagEnd) {
            switch ($tag) {
                case HproseTags::TagResult:
                    if ($resultMode == HproseResultMode::Serialized) {
                        $result = $hproseReader->readRaw()->toString();
                    }
                    else {
                        $hproseReader->reset();
                        $result = &$hproseReader->unserialize();
                    }
                    break;
                case HproseTags::TagArgument:
                    $hproseReader->reset();
                    $args = &$hproseReader->readList();
                    for ($i = 0; $i < count($arguments); $i++) {
                        $arguments[$i] = &$args[$i];
                    }
                    break;
                case HproseTags::TagError:
                    $hproseReader->reset();
                    $error = new HproseException($hproseReader->readString());
                    break;
            }
        }
        if (!is_null($error)) {
            throw $error;
        }
        return $result;
    }
    public function setHeader($name, $value) {
        $lname = strtolower($name);
        if ($lname != 'content-type' &&
            $lname != 'content-length' &&
            $lname != 'host') {
            if ($value) {
                $this->header[$name] = $value;
            }
            else {
                unset($this->header[$name]);
            }
        }
    }
    public function setProxy($proxy = NULL) {
        $this->proxy = $proxy;
    }
    public function setTimeout($timeout) {
        $this->timeout = $timeout;
    }
    public function getTimeout() {
        return $this->timeout;
    }
    public function setKeepAlive($keepAlive = true) {
        $this->keepAlive = $keepAlive;
    }
    public function getKeepAlive() {
        return $this->keeepAlive;
    }
    public function setKeepAliveTimeout($timeout) {
        $this->keepAliveTimeout = $timeout;
    }
    public function getKeepAliveTimeout() {
        return $this->keepAliveTimeout;
    }
    public function getFilter() {
        return $this->filter;
    }
    public function setFilter($filter) {
        $this->filter = $filter;
    }
    public function __call($function, $arguments) {
        return $this->invoke($function, $arguments);
    }
    public function __get($name) {
        return new HproseProxy($this, $name . '_');
    }
}

class HproseProxy {
    private $client;
    private $namespace;
    public function __construct($client, $namespace = '') {
        $this->client = $client;
        $this->namespace = $namespace;
    }
    public function __call($function, $arguments) {
        $function = $this->namespace . $function;
        return $this->client->invoke($function, $arguments);
    }
    public function __get($name) {
        return new HproseProxy($this->client, $this->namespace . $name . '_');
    }
}
?>