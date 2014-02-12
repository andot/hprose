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
 * HproseFormatter.cs                                     *
 *                                                        *
 * hprose formatter class for C#.                         *
 *                                                        *
 * LastModified: Apr 11, 2011                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;
using System.Globalization;
using System.Numerics;
using System.IO;
using System.Text;
using System.Reflection;

namespace Hprose.IO {
    public sealed class HproseFormatter {
        public static MemoryStream Serialize(object obj) {
            MemoryStream stream = new MemoryStream();
            HproseWriter writer = new HproseWriter(stream);
            writer.Serialize(obj);
            return stream;
        }

        public static MemoryStream Serialize(object obj, HproseMode mode) {
            MemoryStream stream = new MemoryStream();
            HproseWriter writer = new HproseWriter(stream, mode);
            writer.Serialize(obj);
            return stream;
        }

        public static void Serialize(object obj, Stream stream) {
            HproseWriter writer = new HproseWriter(stream);
            writer.Serialize(obj);
        }

        public static void Serialize(object obj, Stream stream, HproseMode mode) {
            HproseWriter writer = new HproseWriter(stream, mode);
            writer.Serialize(obj);
        }

        public static object Unserialize(byte[] data) {
                MemoryStream stream = new MemoryStream(data);
            HproseReader reader = new HproseReader(stream);
            return reader.Unserialize();
        }

        public static object Unserialize(byte[] data, HproseMode mode) {
            MemoryStream stream = new MemoryStream(data);
            HproseReader reader = new HproseReader(stream, mode);
            return reader.Unserialize();
        }

        public static object Unserialize(byte[] data, HproseMode mode, Type type) {
            MemoryStream stream = new MemoryStream(data);
            HproseReader reader = new HproseReader(stream, mode);
            return reader.Unserialize(type);
        }

        public static object Unserialize(Stream stream) {
            HproseReader reader = new HproseReader(stream);
            return reader.Unserialize();
        }

        public static object Unserialize(Stream stream, HproseMode mode) {
            HproseReader reader = new HproseReader(stream, mode);
            return reader.Unserialize();
        }

        public static object Unserialize(Stream stream, HproseMode mode, Type type) {
            HproseReader reader = new HproseReader(stream, mode);
            return reader.Unserialize(type);
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public static T Unserialize<T>(byte[] data) {
            MemoryStream stream = new MemoryStream(data);
            HproseReader reader = new HproseReader(stream);
            return reader.Unserialize<T>();
        }

        public static T Unserialize<T>(byte[] data, HproseMode mode) {
            MemoryStream stream = new MemoryStream(data);
            HproseReader reader = new HproseReader(stream, mode);
            return reader.Unserialize<T>();
        }

        public static T Unserialize<T>(Stream stream) {
            HproseReader reader = new HproseReader(stream);
            return reader.Unserialize<T>();
        }

        public static T Unserialize<T>(Stream stream, HproseMode mode) {
            HproseReader reader = new HproseReader(stream, mode);
            return reader.Unserialize<T>();
        }
#endif
    }
}