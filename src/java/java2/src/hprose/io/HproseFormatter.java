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
 * HproseFormatter.java                                   *
 *                                                        *
 * hprose formatter class for Java.                       *
 *                                                        *
 * LastModified: Apr 13, 2011                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public final class HproseFormatter {

    private HproseFormatter() {
    }

    public static OutputStream serialize(byte b, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.writeInteger(b);
        return stream;
    }

    public static OutputStream serialize(short s, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.writeInteger(s);
        return stream;
    }

    public static OutputStream serialize(int i, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.writeInteger(i);
        return stream;
    }

    public static OutputStream serialize(long l, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.writeLong(l);
        return stream;
    }

    public static OutputStream serialize(float f, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.writeDouble(f);
        return stream;
    }

    public static OutputStream serialize(double d, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.writeDouble(d);
        return stream;
    }

    public static OutputStream serialize(boolean b, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.writeBoolean(b);
        return stream;
    }

    public static OutputStream serialize(char c, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.writeUTF8Char(c);
        return stream;
    }

    public static OutputStream serialize(Object obj, OutputStream stream) throws IOException {
        HproseWriter writer = new HproseWriter(stream);
        writer.serialize(obj);
        return stream;
    }

    public static OutputStream serialize(Object obj, OutputStream stream, HproseMode mode) throws IOException {
        HproseWriter writer = new HproseWriter(stream, mode);
        writer.serialize(obj);
        return stream;
    }

    public static ByteArrayOutputStream serialize(byte b) throws IOException {
        return (ByteArrayOutputStream)serialize(b, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(short s) throws IOException {
        return (ByteArrayOutputStream)serialize(s, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(int i) throws IOException {
        return (ByteArrayOutputStream)serialize(i, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(long l) throws IOException {
        return (ByteArrayOutputStream)serialize(l, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(float f) throws IOException {
        return (ByteArrayOutputStream)serialize(f, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(double d) throws IOException {
        return (ByteArrayOutputStream)serialize(d, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(boolean b) throws IOException {
        return (ByteArrayOutputStream)serialize(b, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(char c) throws IOException {
        return (ByteArrayOutputStream)serialize(c, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(Object obj) throws IOException {
        return (ByteArrayOutputStream)serialize(obj, new ByteArrayOutputStream());
    }

    public static ByteArrayOutputStream serialize(Object obj, HproseMode mode) throws IOException {
        return (ByteArrayOutputStream)serialize(obj, new ByteArrayOutputStream(), mode);
    }

    public static Object unserialize(byte[] data) throws IOException {
        ByteArrayInputStream stream = new ByteArrayInputStream(data);
        HproseReader reader = new HproseReader(stream);
        return reader.unserialize();
    }

    public static Object unserialize(byte[] data, HproseMode mode) throws IOException {
        ByteArrayInputStream stream = new ByteArrayInputStream(data);
        HproseReader reader = new HproseReader(stream, mode);
        return reader.unserialize();
    }

    public static Object unserialize(byte[] data, Class type) throws IOException {
        ByteArrayInputStream stream = new ByteArrayInputStream(data);
        HproseReader reader = new HproseReader(stream);
        return reader.unserialize(type);
    }

    public static Object unserialize(byte[] data, HproseMode mode, Class type) throws IOException {
        ByteArrayInputStream stream = new ByteArrayInputStream(data);
        HproseReader reader = new HproseReader(stream, mode);
        return reader.unserialize(type);
    }

    public static Object unserialize(InputStream stream) throws IOException {
        HproseReader reader = new HproseReader(stream);
        return reader.unserialize();
    }

    public static Object unserialize(InputStream stream, HproseMode mode) throws IOException {
        HproseReader reader = new HproseReader(stream, mode);
        return reader.unserialize();
    }

    public static Object unserialize(InputStream stream, Class type) throws IOException {
        HproseReader reader = new HproseReader(stream);
        return reader.unserialize(type);
    }

    public static Object unserialize(InputStream stream, HproseMode mode, Class type) throws IOException {
        HproseReader reader = new HproseReader(stream, mode);
        return reader.unserialize(type);
    }
}
