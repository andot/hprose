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
 * CookieManager.cs                                       *
 *                                                        *
 * cookie manager class for .NET Compact Framework.       *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
#if (PocketPC || Smartphone || WindowsCE)
using System;
using System.Collections;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;

public class CookieManager {
    private static readonly Regex regex = new Regex("=");
    private Hashtable container = new Hashtable();
    public CookieManager() {
    }
    public void SetCookie(string[] cookieList, string host) {
        if (cookieList == null) return;
        lock (this) {
            foreach (string cookieString in cookieList) {
                if (cookieString == "")
                    continue;
                string[] cookies = cookieString.Trim().Split(new char[] { ';' });
                Hashtable cookie = new Hashtable();
                string[] value = regex.Split(cookies[0].Trim(), 2);
                cookie["name"] = value[0];
                if (value.Length == 2)
                    cookie["value"] = value[1];
                else
                    cookie["value"] = "";
                for (int i = 1; i < cookies.Length; i++) {
                    value = regex.Split(cookies[i].Trim(), 2);
                    if (value.Length == 2)
                        cookie[value[0].ToUpper()] = value[1];
                    else
                        cookie[value[0].ToUpper()] = "";
                }
                // Tomcat can return SetCookie2 with path wrapped in "
                if (cookie.ContainsKey("PATH")) {
                    string path = ((string)cookie["PATH"]);
                    if (path[0] == '"')
                        path = path.Substring(1);
                    if (path[path.Length - 1] == '"')
                        path = path.Substring(0, path.Length - 1);
                    cookie["PATH"] = path;
                }
                else {
                    cookie["PATH"] = "/";
                }
                if (cookie.ContainsKey("EXPIRES")) {
                    cookie["EXPIRES"] = DateTime.Parse((string)cookie["EXPIRES"]);
                }
                if (cookie.ContainsKey("DOMAIN")) {
                    cookie["DOMAIN"] = ((string)cookie["DOMAIN"]).ToLower();
                }
                else {
                    cookie["DOMAIN"] = host;
                }
                cookie["SECURE"] = cookie.ContainsKey("SECURE");
                if (!container.ContainsKey(cookie["DOMAIN"])) {
                    container[cookie["DOMAIN"]] = new Hashtable();
                }
                ((Hashtable)container[cookie["DOMAIN"]])[cookie["name"]] = cookie;
            }
        }
    }

    public string GetCookie(string host, string path, bool secure) {
        lock(this) {
            StringBuilder cookies = new StringBuilder();
            foreach (DictionaryEntry entry in container) {
                string domain = (string) entry.Key;
                Hashtable cookieList = (Hashtable)entry.Value;
                if (host.EndsWith(domain)) {
                    ArrayList names = new ArrayList();
                    foreach (DictionaryEntry entry2 in cookieList) {
                        Hashtable cookie = (Hashtable)entry2.Value;
                        if (cookie.ContainsKey("EXPIRES") && DateTime.Now > (DateTime)cookie["EXPIRES"]) {
                            names.Add(entry2.Key);
                        }
                        else if (path.StartsWith((string)cookie["PATH"])) {
                            if (((secure && (bool)cookie["SECURE"]) || !(bool)cookie["SECURE"]) && (string)cookie["value"] != "") {
                                if (cookies.Length != 0) {
                                    cookies.Append("; ");
                                }
                                cookies.Append(cookie["name"]);
                                cookies.Append('=');
                                cookies.Append(cookie["value"]);
                            }
                        }
                    }
                    foreach (object name in names) {
                        ((Hashtable)container[domain]).Remove(name);
                    }
                }
            }
            return cookies.ToString();
        }
    }
}
#endif