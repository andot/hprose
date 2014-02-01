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
 * HproseHttpService.java                                 *
 *                                                        *
 * hprose http service class for Java.                    *
 *                                                        *
 * LastModified: Feb 1, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.server;

import hprose.common.HproseMethods;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class HproseHttpService extends HproseService {
    private boolean crossDomainEnabled = false;
    private boolean p3pEnabled = false;
    private boolean getEnabled = true;
    private static ThreadLocal context = new ThreadLocal();

    public static HttpContext getCurrentContext() {
        return (HttpContext)context.get();
    }

    public HproseMethods getGlobalMethods() {
        if (globalMethods == null) {
            globalMethods = new HproseHttpMethods();
        }
        return globalMethods;
    }

    public void setGlobalMethods(HproseMethods methods) {
        if (methods instanceof HproseHttpMethods) {
            this.globalMethods = methods;
        }
        else {
            throw new ClassCastException("methods must be a HproseHttpMethods instance");
        }
    }
    
    public boolean isCrossDomainEnabled() {
        return crossDomainEnabled;
    }

    public void setCrossDomainEnabled(boolean enabled) {
        crossDomainEnabled = enabled;
    }    

    public boolean isP3pEnabled() {
        return p3pEnabled;
    }

    public void setP3pEnabled(boolean enabled) {
        p3pEnabled = enabled;
    }

    public boolean isGetEnabled() {
        return getEnabled;
    }

    public void setGetEnabled(boolean enabled) {
        getEnabled = enabled;
    }

    protected Object[] fixArguments(Class[] argumentTypes, Object[] arguments, int count) {
        if (argumentTypes.length != count) {
            Object[] args = new Object[argumentTypes.length];
            System.arraycopy(arguments, 0, args, 0, count);
            Class argType = argumentTypes[count];
            HttpContext httpContext = getCurrentContext();
            if (argType.equals(HttpContext.class)) {
                args[count] = httpContext;
            }
            else if (argType.equals(HttpServletRequest.class)) {
                args[count] = httpContext.getRequest();
            }
            else if (argType.equals(HttpServletResponse.class)) {
                args[count] = httpContext.getResponse();
            }
            else if (argType.equals(HttpSession.class)) {
                args[count] = httpContext.getSession();
            }
            else if (argType.equals(ServletContext.class)) {
                args[count] = httpContext.getApplication();
            }
            else if (argType.equals(ServletConfig.class)) {
                args[count] = httpContext.getConfig();
            }
            return args;
        }
        return arguments;
    }

    protected void sendHeader(HttpContext httpContext) throws IOException {
        if (event != null && HproseHttpServiceEvent.class.isInstance(event)) {
            ((HproseHttpServiceEvent)event).onSendHeader(httpContext);
        }
        HttpServletRequest request = httpContext.getRequest();
        HttpServletResponse response = httpContext.getResponse();
        response.setContentType("text/plain");
        if (p3pEnabled) {
            response.setHeader("P3P", "CP=\"CAO DSP COR CUR ADM DEV TAI PSA PSD " +
                                      "IVAi IVDi CONi TELo OTPi OUR DELi SAMi " +
                                      "OTRi UNRi PUBi IND PHY ONL UNI PUR FIN " +
                                      "COM NAV INT DEM CNT STA POL HEA PRE GOV\"");
        }
        if (crossDomainEnabled) {
            String origin = request.getHeader("Origin");
            if (origin != null && !origin.equals("null")) {
                response.setHeader("Access-Control-Allow-Origin", origin);
                response.setHeader("Access-Control-Allow-Credentials", "true");  
            }
            else {
                response.setHeader("Access-Control-Allow-Origin", "*");
            }
        }
    }

    public void handle(HttpContext httpContext) throws IOException {
        handle(httpContext, null);
    }
    public void handle(HttpContext httpContext, HproseHttpMethods methods) throws IOException {
        try {
            context.set(httpContext);
            sendHeader(httpContext);
            String method = httpContext.getRequest().getMethod();
            if (method.equals("GET") && getEnabled) {
                OutputStream ostream = new BufferedOutputStream(httpContext.getResponse().getOutputStream());
                doFunctionList(ostream, methods);
            }
            else if (method.equals("POST")) {
                InputStream istream = new BufferedInputStream(httpContext.getRequest().getInputStream());
                OutputStream ostream = new BufferedOutputStream(httpContext.getResponse().getOutputStream());
                super.handle(istream, ostream, methods);
            }
            else {
                httpContext.getResponse().sendError(HttpServletResponse.SC_FORBIDDEN);
            }
        }
        finally {
            context.set(null);
        }
    }
}