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
 * HproseInvoker.java                                     *
 *                                                        *
 * hprose invoker interface for Java.                     *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.io.IOException;

public interface HproseInvoker {
    void invoke(String functionName, HproseCallback callback);
    void invoke(String functionName, HproseCallback callback, HproseErrorEvent errorEvent);
    void invoke(String functionName, Object[] arguments, HproseCallback callback);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, boolean byRef);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, boolean byRef);

    void invoke(String functionName, HproseCallback callback, Class returnType);
    void invoke(String functionName, HproseCallback callback, HproseErrorEvent errorEvent, Class returnType);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, Class returnType);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Class returnType);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, Class returnType, boolean byRef);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Class returnType, boolean byRef);

    void invoke(String functionName, HproseCallback callback, HproseResultMode resultMode);
    void invoke(String functionName, HproseCallback callback, HproseErrorEvent errorEvent, HproseResultMode resultMode);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseResultMode resultMode);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, HproseResultMode resultMode);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, boolean byRef, HproseResultMode resultMode);
    void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, boolean byRef, HproseResultMode resultMode);

    Object invoke(String functionName) throws IOException;
    Object invoke(String functionName, Object[] arguments) throws IOException;
    Object invoke(String functionName, Object[] arguments, boolean byRef) throws IOException;

    Object invoke(String functionName, Class returnType) throws IOException;
    Object invoke(String functionName, Object[] arguments, Class returnType) throws IOException;
    Object invoke(String functionName, Object[] arguments, Class returnType, boolean byRef) throws IOException;

    Object invoke(String functionName, HproseResultMode resultMode) throws IOException;
    Object invoke(String functionName, Object[] arguments, HproseResultMode resultMode) throws IOException;
    Object invoke(String functionName, Object[] arguments, boolean byRef, HproseResultMode resultMode) throws IOException;
}