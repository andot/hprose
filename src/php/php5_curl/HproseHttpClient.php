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
 * LastModified: Nov 27, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require_once('HproseCommon.php');
require_once('HproseIO.php');

class HproseHttpClient {
    private $curl;
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
            return "Cookie: " . implode('; ', $cookies);
        }
        return '';
    }
    public function __construct($url = '') {
        $this->useService($url);
        $this->header = array('Content-type' => 'application/hprose');
        $this->curl = curl_init();
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
    public function invoke($functionName, &$arguments = array(), $byRef = false, $resultMode = HproseResultMode::Normal) {
        $stream = new HproseStringStream(HproseTags::TagCall);
        $hproseWriter = new HproseWriter($stream);
        $hproseWriter->writeString($functionName, false);
        if (count($arguments) > 0 || $byRef) {
            $hproseWriter->reset();
            $hproseWriter->writeList($arguments, false);
        }
        if ($byRef) {
            $hproseWriter->writeBoolean(true);
        }
        $stream->write(HproseTags::TagEnd);
        $request = $stream->toString();
        if ($this->filter) $request = $this->filter->outputFilter($request);
        $stream->close();
        curl_setopt($this->curl, CURLOPT_URL, $this->url);
        curl_setopt($this->curl, CURLOPT_HEADER, TRUE);
        curl_setopt($this->curl, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($this->curl, CURLOPT_RETURNTRANSFER, TRUE);
        curl_setopt($this->curl, CURLOPT_POST, TRUE);
        curl_setopt($this->curl, CURLOPT_POSTFIELDS, $request);
        $headers_array = array($this->getCookie(),
                                "Content-Length: " . strlen($request));
        if ($this->keepAlive) {
            $headers_array[] = "Connection: keep-alive";
            $headers_array[] = "Keep-Alive: " . $this->keepAliveTimeout;
        }
        else {
            $headers_array[] = "Connection: close";
        }
        foreach ($this->header as $name => $value) {
            $headers_array[] = $name . ": " . $value;
        }
        curl_setopt($this->curl, CURLOPT_HTTPHEADER, $headers_array);
        if ($this->proxy) {
            curl_setopt($this->curl, CURLOPT_PROXY, $this->proxy);
        }
        if (defined(CURLOPT_TIMEOUT_MS)) {
            curl_setopt($this->curl, CURLOPT_TIMEOUT_MS, $this->timeout);
        }
        else {
            curl_setopt($this->curl, CURLOPT_TIMEOUT, $this->timeout / 1000);
        }
        $response = curl_exec($this->curl);
        $errno = curl_errno($this->curl);
        if ($errno) {
            throw new HproseException($errno . ": " . curl_error($this->curl));
        }
        do {
            list($response_headers, $response) = explode("\r\n\r\n", $response, 2); 
            $http_response_header = explode("\r\n", $response_headers);
            $http_response_firstline = array_shift($http_response_header); 
            if (preg_match('@^HTTP/[0-9]\.[0-9]\s([0-9]{3})\s(.*?)@',
                           $http_response_firstline, $matches)) { 
                $response_code = $matches[1];
                $response_status = trim($matches[2]);
            }
            else {
                $response_code = "500";
                $response_status = "Unknown Error.";                
            }
        } while (substr($response_code, 0, 1) == "1");
        if ($response_code != '200') {
            throw new HproseException($response_code . ": " . $response_status);
        }
        $this->setCookie($http_response_header);
        if ($this->filter) $response = $this->filter->inputFilter($response);
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
    public funtion setFilter($filter) {
        $this->filter = $filter;
    }
    public function __call($function, $arguments) {
        return $this->invoke($function, $arguments);
    }
    public function __get($name) {
        return new HproseProxy($this, $name . '_');
    }
    public function __destruct(){
    	curl_close($this->curl);
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