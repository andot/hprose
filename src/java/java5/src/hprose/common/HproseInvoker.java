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
import java.lang.reflect.Type;

public interface HproseInvoker {
    void invoke(String functionName, HproseCallback<?> callback);
    void invoke(String functionName, HproseCallback<?> callback, HproseErrorEvent errorEvent);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, HproseErrorEvent errorEvent);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, boolean byRef);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, HproseErrorEvent errorEvent, boolean byRef);

    void invoke(String functionName, HproseCallback<?> callback, Type returnType);
    void invoke(String functionName, HproseCallback<?> callback, HproseErrorEvent errorEvent, Type returnType);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, Type returnType);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, HproseErrorEvent errorEvent, Type returnType);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, Type returnType, boolean byRef);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, HproseErrorEvent errorEvent, Type returnType, boolean byRef);

    void invoke(String functionName, HproseCallback<?> callback, HproseResultMode resultMode);
    void invoke(String functionName, HproseCallback<?> callback, HproseErrorEvent errorEvent, HproseResultMode resultMode);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, HproseResultMode resultMode);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, HproseErrorEvent errorEvent, HproseResultMode resultMode);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, boolean byRef, HproseResultMode resultMode);
    void invoke(String functionName, Object[] arguments, HproseCallback<?> callback, HproseErrorEvent errorEvent, boolean byRef, HproseResultMode resultMode);

    <T> void invoke(String functionName, HproseCallback<T> callback, Class<T> returnType);
    <T> void invoke(String functionName, HproseCallback<T> callback, HproseErrorEvent errorEvent, Class<T> returnType);
    <T> void invoke(String functionName, Object[] arguments, HproseCallback<T> callback, Class<T> returnType);
    <T> void invoke(String functionName, Object[] arguments, HproseCallback<T> callback, HproseErrorEvent errorEvent, Class<T> returnType);
    <T> void invoke(String functionName, Object[] arguments, HproseCallback<T> callback, Class<T> returnType, boolean byRef);
    <T> void invoke(String functionName, Object[] arguments, HproseCallback<T> callback, HproseErrorEvent errorEvent, Class<T> returnType, boolean byRef);

    Object invoke(String functionName) throws IOException;
    Object invoke(String functionName, Object[] arguments) throws IOException;
    Object invoke(String functionName, Object[] arguments, boolean byRef) throws IOException;

    Object invoke(String functionName, Type returnType) throws IOException;
    Object invoke(String functionName, Object[] arguments, Type returnType) throws IOException;
    Object invoke(String functionName, Object[] arguments, Type returnType, boolean byRef) throws IOException;

    Object invoke(String functionName, HproseResultMode resultMode) throws IOException;
    Object invoke(String functionName, Object[] arguments, HproseResultMode resultMode) throws IOException;
    Object invoke(String functionName, Object[] arguments, boolean byRef, HproseResultMode resultMode) throws IOException;

    <T> T invoke(String functionName, Class<T> returnType) throws IOException;
    <T> T invoke(String functionName, Object[] arguments, Class<T> returnType) throws IOException;
    <T> T invoke(String functionName, Object[] arguments, Class<T> returnType, boolean byRef) throws IOException;
}