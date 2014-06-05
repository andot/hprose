/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseHttpClient.java                                  *
 *                                                        *
 * hprose http client class for Java.                     *
 *                                                        *
 * LastModified: Jun 28, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.client;

import hprose.io.HproseHelper;
import hprose.io.HproseMode;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;

public class HproseHttpClient extends HproseClient {

    private String uri;
    private HashMap headers = new HashMap();
    private static CookieManager cookieManager = new CookieManager();
    private boolean keepAlive = false;
    private int keepAliveTimeout = 300;
    private String proxyHost = null;
    private int proxyPort = 80;
    private String proxyUser = null;
    private String proxyPass = null;
    private int timeout = -1;

    public HproseHttpClient() {
        super();
    }

    public HproseHttpClient(String uri) {
        super(uri);
    }

    public HproseHttpClient(HproseMode mode) {
        super(mode);
    }

    public HproseHttpClient(String uri, HproseMode mode) {
        super(uri, mode);
    }

    public void useService(String uri) {
        this.uri = uri;
    }

    public void setHeader(String name, String value) {
        String nl = name.toLowerCase();
        if (!nl.equals("content-type") &&
            !nl.equals("content-length") &&
            !nl.equals("connection") &&
            !nl.equals("keep-alive") &&
            !nl.equals("host")) {
            if (value == null) {
                headers.remove(name);
            }
            else {
                headers.put(name, value);
            }
        }
    }

    public String getHeader(String name) {
        return (String) headers.get(name);
    }

    public boolean isKeepAlive() {
        return keepAlive;
    }

    public void setKeepAlive(boolean keepAlive) {
        this.keepAlive = keepAlive;
    }

    public int getKeepAliveTimeout() {
        return keepAliveTimeout;
    }

    public void setKeepAliveTimeout(int keepAliveTimeout) {
        this.keepAliveTimeout = keepAliveTimeout;
    }

    public String getProxyHost() {
        return proxyHost;
    }

    public void setProxyHost(String proxyHost) {
        this.proxyHost = proxyHost;
    }

    public int getProxyPort() {
        return proxyPort;
    }

    public void setProxyPort(int proxyPort) {
        this.proxyPort = proxyPort;
    }

    public String getProxyUser() {
        return proxyUser;
    }

    public void setProxyUser(String proxyUser) {
        this.proxyUser = proxyUser;
    }

    public String getProxyPass() {
        return proxyPass;
    }

    public void setProxyPass(String proxyPass) {
        this.proxyPass = proxyPass;
    }

    public int getTimeout() {
        return timeout;
    }

    public void setTimeout(int timeout) {
        this.timeout = timeout;
        System.setProperty("sun.net.client.defaultConnectTimeout", Integer.toString(timeout));
        System.setProperty("sun.net.client.defaultReadTimeout", Integer.toString(timeout));
    }

    protected Object getInvokeContext() throws IOException {
        URL url = new URL(uri);
        Properties prop = System.getProperties();
        prop.put("http.keepAlive", Boolean.toString(keepAlive));
        if (proxyHost != null) {
            prop.put("http.proxyHost", proxyHost);
            prop.put("http.proxyPort", Integer.toString(proxyPort));
        }
        else {
            prop.remove("http.proxyHost");
            prop.remove("http.proxyPort");
        }
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestProperty("Cookie", cookieManager.getCookie(url.getHost(),
                                                                  url.getFile(),
                                                                  url.getProtocol().equals("https")));
        if (keepAlive) {
            conn.setRequestProperty("Keep-Alive", Integer.toString(keepAliveTimeout));
        }
        if (proxyUser != null && proxyPass != null) {
            conn.setRequestProperty("Proxy-Authorization",
                "Basic " + HproseHelper.base64Encode((proxyUser + ":" + proxyPass).getBytes()));
        }
        for (Iterator iter = headers.entrySet().iterator(); iter.hasNext();) {
            Entry entry = (Entry) iter.next();
            conn.setRequestProperty((String) entry.getKey(), (String) entry.getValue());
        }
        return conn;
    }

    protected OutputStream getOutputStream(Object context) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) context;
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/hprose");
        OutputStream ostream = conn.getOutputStream();
        return new BufferedOutputStream(ostream);
    }

    protected void sendData(OutputStream ostream, Object context, boolean success) throws IOException {
        ostream.flush();
        ostream.close();
    }

    protected InputStream getInputStream(Object context) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) context;
        int i = 1;
        String key = null;
        List cookieList = new ArrayList();
        while((key=conn.getHeaderFieldKey(i)) != null) {
            if (key.equalsIgnoreCase("set-cookie") ||
                key.equalsIgnoreCase("set-cookie2")) {
                cookieList.add(conn.getHeaderField(i));
            }
            i++;
        }
        URL url =conn.getURL();
        cookieManager.setCookie(cookieList, url.getHost());
        InputStream istream = conn.getInputStream();
        return new BufferedInputStream(istream);
    }

    protected void endInvoke(InputStream istream, Object context, boolean success) throws IOException {
        istream.close();
    }
}
