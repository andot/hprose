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
 * HproseServlet.java                                     *
 *                                                        *
 * hprose servlet class for Java.                         *
 *                                                        *
 * LastModified: Jun 26, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.server;

import hprose.common.HproseMethods;
import hprose.io.ClassManager;
import hprose.io.HproseHelper;
import hprose.io.HproseMode;
import java.io.IOException;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class HproseServlet extends HttpServlet {

    private static final long serialVersionUID = 1716958719284073368L;
    private HproseHttpService service = new HproseHttpService();

    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        String param = config.getInitParameter("mode");
        if (param != null) {
            param = param.toLowerCase();
            if (param.equals("propertymode")) {
                service.setMode(HproseMode.PropertyMode);
            }
        }
        param = config.getInitParameter("debug");
        if (param != null) {
            param = param.toLowerCase();
            if (param.equals("true")) {
                service.setDebugEnabled(true);
            }
        }
        param = config.getInitParameter("crossDomain");
        if (param != null) {
            param = param.toLowerCase();
            if (param.equals("true")) {
                service.setCrossDomainEnabled(true);
            }
        }
        param = config.getInitParameter("p3p");
        if (param != null) {
            param = param.toLowerCase();
            if (param.equals("true")) {
                service.setP3pEnabled(true);
            }
        }
        param = config.getInitParameter("get");
        if (param != null) {
            param = param.toLowerCase();
            if (param.equals("false")) {
                service.setGetEnabled(false);
            }
        }
        param = config.getInitParameter("event");
        if (param != null) {
            try {
                Class type = Class.forName(param);
                if (HproseServiceEvent.class.isAssignableFrom(type)) {
                    service.setEvent((HproseServiceEvent) type.newInstance());
                }
            }
            catch (Exception ex) {
                throw new ServletException(ex);
            }
        }
        HproseMethods methods = service.getGlobalMethods();
        param = config.getInitParameter("class");
        if (param != null) {
            try {
                String[] classNames = HproseHelper.split(param, ',', 0);
                for (int i = 0, n = classNames.length; i < n; i++) {
                    String[] name = HproseHelper.split(classNames[i], '|', 3);
                    Class type = Class.forName(name[0]);
                    Object obj = type.newInstance();
                    Class ancestorType;
                    if (name.length == 1) {
                        methods.addInstanceMethods(obj, type);
                    }
                    else if (name.length == 2) {
                        for (ancestorType = Class.forName(name[1]);
                             ancestorType.isAssignableFrom(type);
                             type = type.getSuperclass()) {
                            methods.addInstanceMethods(obj, type);
                        }
                    }
                    else if (name.length == 3) {
                        if (name[1].equals("")) {
                            methods.addInstanceMethods(obj, type, name[2]);
                        }
                        else {
                            for (ancestorType = Class.forName(name[1]);
                                 ancestorType.isAssignableFrom(type);
                                 type = type.getSuperclass()) {
                                methods.addInstanceMethods(obj, type, name[2]);
                            }
                        }
                    }
                }
            }
            catch (Exception ex) {
                throw new ServletException(ex);
            }
        }
        param = config.getInitParameter("staticClass");
        if (param != null) {
            try {
                String[] classNames = HproseHelper.split(param, ',', 0);
                for (int i = 0, n = classNames.length; i < n; i++) {
                    String[] name = HproseHelper.split(classNames[i], '|', 2);
                    Class type = Class.forName(name[0]);
                    if (name.length == 1) {
                        methods.addStaticMethods(type);
                    }
                    else {
                        methods.addStaticMethods(type, name[1]);
                    }
                }
            }
            catch (Exception ex) {
                throw new ServletException(ex);
            }
        }
        param = config.getInitParameter("type");
        if (param != null) {
            try {
                String[] classNames = HproseHelper.split(param, ',', 0);
                for (int i = 0, n = classNames.length; i < n; i++) {
                    String[] name = HproseHelper.split(classNames[i], '|', 2);
                    ClassManager.register(Class.forName(name[0]), name[1]);
                }
            }
            catch (Exception ex) {
                throw new ServletException(ex);
            }
        }
        setGlobalMethods(methods);
    }

    protected void setGlobalMethods(HproseMethods methods) {
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        service.handle(new HttpContext(request,
                                      response,
                       this.getServletConfig(),
                    this.getServletContext()));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    public String getServletInfo() {
        return "Hprose Servlet 1.0";
    }
}
