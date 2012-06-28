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
 * HproseHttpClient.java                                  *
 *                                                        *
 * hprose http client class for Java.                     *
 *                                                        *
 * LastModified: May 25, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.client;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;

public class HproseHttpClient extends HproseClient {

    private String uri;
    private HashMap headers = new HashMap();
    private static CookieManager cookieManager = new CookieManager();
    private boolean keepAlive = false;
    private int keepAliveTimeout = 300;

    public HproseHttpClient() {
        super();
    }

    public HproseHttpClient(String uri) {
        super(uri);
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

    protected Object getInvokeContext() throws IOException {
        HttpConnection conn = (HttpConnection)Connector.open(uri, Connector.READ_WRITE);
        if (keepAlive) {
            conn.setRequestProperty("Connection", "Keep-Alive");
            conn.setRequestProperty("Keep-Alive", Integer.toString(keepAliveTimeout));
        }
        else {
            conn.setRequestProperty("Connection", "Close");
        }
        conn.setRequestProperty("Cookie", cookieManager.getCookie(conn.getHost(),
                                                                  conn.getFile(),
                                                                  conn.getProtocol().equals("https")));
        for (Iterator iter = headers.entrySet().iterator(); iter.hasNext();) {
            Entry entry = (Entry) iter.next();
            conn.setRequestProperty((String) entry.getKey(), (String) entry.getValue());
        }
        return conn;
    }

    protected OutputStream getOutputStream(Object context) throws IOException {
        HttpConnection conn = (HttpConnection) context;
        conn.setRequestMethod(HttpConnection.POST);
        conn.setRequestProperty("Content-Type", "application/hprose");
        OutputStream ostream = conn.openOutputStream();
        return ostream;
    }

    protected void sendData(OutputStream ostream, Object context, boolean success) throws IOException {
        ostream.flush();
        ostream.close();
    }

    protected InputStream getInputStream(Object context) throws IOException {
        HttpConnection conn = (HttpConnection) context;
        int i = 0;
        String key = null;
        ArrayList cookieList = new ArrayList();
        while((key=conn.getHeaderFieldKey(i)) != null) {
            if (key.equalsIgnoreCase("set-cookie") ||
                key.equalsIgnoreCase("set-cookie2")) {
                cookieList.add(conn.getHeaderField(i));
            }
            i++;
        }
        cookieManager.setCookie(cookieList, conn.getHost());
        InputStream istream = conn.openInputStream();
        return istream;
    }

    protected void endInvoke(InputStream istream, Object context, boolean success) throws IOException {
        istream.close();
    }

}