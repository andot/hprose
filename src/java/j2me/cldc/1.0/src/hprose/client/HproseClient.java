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
 * HproseClient.java                                      *
 *                                                        *
 * hprose client class for Java.                          *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.client;

import hprose.common.HproseErrorEvent;
import hprose.common.HproseCallback;
import hprose.common.HproseInvoker;
import hprose.common.HproseException;
import hprose.common.HproseResultMode;
import hprose.io.HproseHelper;
import hprose.io.HproseWriter;
import hprose.io.HproseReader;
import hprose.io.HproseTags;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public abstract class HproseClient implements HproseInvoker {

    private static final Object[] nullArgs = new Object[0];
    public HproseErrorEvent onError = null;

    protected HproseClient() {
    }

    protected HproseClient(String uri) {
        useService(uri);
    }

    public abstract void useService(String uri);


    public final void invoke(String functionName, HproseCallback callback) {
        invoke(functionName, nullArgs, callback, null, null, false, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, HproseCallback callback, HproseErrorEvent errorEvent) {
        invoke(functionName, nullArgs, callback, errorEvent, null, false, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback) {
        invoke(functionName, arguments, callback, null, null, false, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent) {
        invoke(functionName, arguments, callback, errorEvent, null, false, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, boolean byRef) {
        invoke(functionName, arguments, callback, null, null, byRef, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, boolean byRef) {
        invoke(functionName, arguments, callback, errorEvent, null, byRef, HproseResultMode.Normal);
    }

    public final void invoke(String functionName, HproseCallback callback, Class returnType) {
        invoke(functionName, nullArgs, callback, null, returnType, false, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, HproseCallback callback, HproseErrorEvent errorEvent, Class returnType) {
        invoke(functionName, nullArgs, callback, errorEvent, returnType, false, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, Class returnType) {
        invoke(functionName, arguments, callback, null, returnType, false, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Class returnType) {
        invoke(functionName, arguments, callback, errorEvent, returnType, false, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, Class returnType, boolean byRef) {
        invoke(functionName, arguments, callback, null, returnType, byRef, HproseResultMode.Normal);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Class returnType, boolean byRef) {
        invoke(functionName, arguments, callback, errorEvent, returnType, byRef, HproseResultMode.Normal);
    }

    public final void invoke(String functionName, HproseCallback callback, HproseResultMode resultMode) {
        invoke(functionName, nullArgs, callback, null, null, false, resultMode);
    }
    public final void invoke(String functionName, HproseCallback callback, HproseErrorEvent errorEvent, HproseResultMode resultMode) {
        invoke(functionName, nullArgs, callback, errorEvent, null, false, resultMode);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseResultMode resultMode) {
        invoke(functionName, arguments, callback, null, null, false, resultMode);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, HproseResultMode resultMode) {
        invoke(functionName, arguments, callback, errorEvent, null, false, resultMode);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, boolean byRef, HproseResultMode resultMode) {
        invoke(functionName, arguments, callback, null, null, byRef, resultMode);
    }
    public final void invoke(String functionName, Object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, boolean byRef, HproseResultMode resultMode) {
        invoke(functionName, arguments, callback, errorEvent, null, byRef, resultMode);
    }

    private void invoke(final String functionName, final Object[] arguments, final HproseCallback callback, final HproseErrorEvent errorEvent, final Class returnType, final boolean byRef, final HproseResultMode resultMode) {
        new Thread() {
            public void run() {
                try {
                    Object result = invoke(functionName, arguments, returnType, byRef, resultMode);
                    callback.handler(result, arguments);
                }
                catch (Throwable ex) {
                    if (errorEvent != null) {
                        errorEvent.handler(functionName, ex);
                    }
                    else if (onError != null) {
                        onError.handler(functionName, ex);
                    }
                }
            }
        }.start();
    }

    public final Object invoke(String functionName) throws IOException {
        return invoke(functionName, nullArgs, (Class)null, false, HproseResultMode.Normal);
    }
    public final Object invoke(String functionName, Object[] arguments) throws IOException {
        return invoke(functionName, arguments, (Class)null, false, HproseResultMode.Normal);
    }
    public final Object invoke(String functionName, Object[] arguments, boolean byRef) throws IOException {
        return invoke(functionName, arguments, (Class)null, byRef, HproseResultMode.Normal);
    }

    public final Object invoke(String functionName, Class returnType) throws IOException {
        return invoke(functionName, nullArgs, returnType, false, HproseResultMode.Normal);
    }
    public final Object invoke(String functionName, Object[] arguments, Class returnType) throws IOException {
        return invoke(functionName, arguments, returnType, false, HproseResultMode.Normal);
    }
    public final Object invoke(String functionName, Object[] arguments, Class returnType, boolean byRef) throws IOException {
        return invoke(functionName, arguments, returnType, byRef, HproseResultMode.Normal);
    }

    public final Object invoke(String functionName, HproseResultMode resultMode) throws IOException {
        return invoke(functionName, nullArgs, (Class)null, false, resultMode);
    }
    public final Object invoke(String functionName, Object[] arguments, HproseResultMode resultMode) throws IOException {
        return invoke(functionName, arguments, (Class)null, false, resultMode);
    }
    public final Object invoke(String functionName, Object[] arguments, boolean byRef, HproseResultMode resultMode) throws IOException {
        return invoke(functionName, arguments, (Class)null, byRef, resultMode);
    }

    private Object invoke(String functionName, Object[] arguments, Class returnType, boolean byRef, HproseResultMode resultMode) throws IOException {
        Object context = getInvokeContext();
        OutputStream ostream = getOutputStream(context);
        boolean success = false;
        try {
            doOutput(functionName, arguments, byRef, ostream);
            success = true;
        }
        finally {
            sendData(ostream, context, success);
        }
        Object result = null;
        InputStream istream = getInputStream(context);
        success = false;
        try {
            result = doInput(arguments, returnType, resultMode, istream);
            success = true;
        }
        finally {
            endInvoke(istream, context, success);
        }
        if (result instanceof HproseException) {
            throw (HproseException) result;
        }
        return result;
    }

    private Object doInput(Object[] arguments, Class returnType, HproseResultMode resultMode, InputStream istream) throws IOException {
        int tag;
        Object result = null;
        HproseReader hproseReader = new HproseReader(istream);
        ByteArrayOutputStream bytestream = null;
        if (resultMode == HproseResultMode.RawWithEndTag || resultMode == HproseResultMode.Raw) {
            bytestream = new ByteArrayOutputStream();
        }
        while ((tag = hproseReader.checkTags(
                (char) HproseTags.TagResult + "" +
                (char) HproseTags.TagArgument + "" +
                (char) HproseTags.TagError + "" +
                (char) HproseTags.TagEnd)) != HproseTags.TagEnd) {
            switch (tag) {
                case HproseTags.TagResult:
                    if (resultMode == HproseResultMode.Normal) {
                        hproseReader.reset();
                        result = hproseReader.unserialize(returnType);
                    }
                    else if (resultMode == HproseResultMode.Serialized) {
                        result = hproseReader.readRaw();
                    }
                    else {
                        bytestream.write(HproseTags.TagResult);
                        hproseReader.readRaw(bytestream);
                    }
                    break;
                case HproseTags.TagArgument:
                    if (resultMode == HproseResultMode.RawWithEndTag || resultMode == HproseResultMode.Raw) {
                        bytestream.write(HproseTags.TagArgument);
                        hproseReader.readRaw(bytestream);
                    }
                    else {
                        hproseReader.reset();
                        Object[] args = (Object[]) hproseReader.readList(HproseHelper.ObjectArrayClass);
                        System.arraycopy(args, 0, arguments, 0, arguments.length);
                    }
                    break;
                case HproseTags.TagError:
                    if (resultMode == HproseResultMode.RawWithEndTag || resultMode == HproseResultMode.Raw) {
                        bytestream.write(HproseTags.TagError);
                        hproseReader.readRaw(bytestream);
                    }
                    else {
                        hproseReader.reset();
                        result = new HproseException((String) hproseReader.readString());
                    }
                    break;
            }
        }
        if (resultMode == HproseResultMode.RawWithEndTag || resultMode == HproseResultMode.Raw) {
            if (resultMode == HproseResultMode.RawWithEndTag) {
                bytestream.write(HproseTags.TagEnd);
            }
            result = bytestream;
        }
        return result;
    }

    private void doOutput(String functionName, Object[] arguments, boolean byRef, OutputStream ostream) throws IOException {
        HproseWriter hproseWriter = new HproseWriter(ostream);
        ostream.write(HproseTags.TagCall);
        hproseWriter.writeString(functionName, false);
        if ((arguments != null) && (arguments.length > 0 || byRef)) {
            hproseWriter.reset();
            hproseWriter.writeArray(arguments, false);
            if (byRef) {
                hproseWriter.writeBoolean(true);
            }
        }
        ostream.write(HproseTags.TagEnd);
    }

    protected abstract Object getInvokeContext() throws IOException;

    protected abstract OutputStream getOutputStream(Object context) throws IOException;

    protected abstract void sendData(OutputStream ostream, Object context, boolean success) throws IOException;

    protected abstract InputStream getInputStream(Object context) throws IOException;

    protected abstract void endInvoke(InputStream istream, Object context, boolean success) throws IOException;
}
