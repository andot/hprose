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
 * HproseService.cs                                       *
 *                                                        *
 * hprose service class for C#.                           *
 *                                                        *
 * LastModified: Dec 16, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
#if !ClientOnly
using System;
using System.Collections;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif
using System.IO;
using System.Reflection;
using Hprose.IO;
using Hprose.Common;

namespace Hprose.Server {

    public abstract class HproseService {

        private HproseMode mode = HproseMode.FieldMode;
        private bool debugEnabled = false;
        protected HproseMethods globalMethods = null;
        public event BeforeInvokeEvent OnBeforeInvoke = null;
        public event AfterInvokeEvent OnAfterInvoke = null;
        public event SendHeaderEvent OnSendHeader = null;
        public event SendErrorEvent OnSendError = null;
        private IHproseFilter filter = null;

        public virtual HproseMethods GlobalMethods {
            get {
                if (globalMethods == null) {
                    globalMethods = new HproseMethods();
                }
                return globalMethods;
            }
            set {
                globalMethods = value;
            }
        }

        public HproseMode Mode {
            get {
                return mode;
            }
            set {
                mode = value;
            }
        }

        public bool IsDebugEnabled {
            get {
                return debugEnabled;
            }
            set {
                debugEnabled = value;
            }
        }

        public IHproseFilter Filter {
            get {
                return filter;
            }
            set {
                filter = value;
            }
        }
        
        public void Add(MethodInfo method, object obj, string aliasName) {
            GlobalMethods.AddMethod(method, obj, aliasName);
        }

        public void Add(MethodInfo method, object obj, string aliasName, HproseResultMode mode) {
            GlobalMethods.AddMethod(method, obj, aliasName, mode);
        }

        public void Add(string methodName, object obj, Type[] paramTypes, string aliasName) {
            GlobalMethods.AddMethod(methodName, obj, paramTypes, aliasName);
        }

        public void Add(string methodName, object obj, Type[] paramTypes, string aliasName, HproseResultMode mode) {
            GlobalMethods.AddMethod(methodName, obj, paramTypes, aliasName, mode);
        }

        public void Add(string methodName, Type type, Type[] paramTypes, string aliasName) {
            GlobalMethods.AddMethod(methodName, type, paramTypes, aliasName);
        }

        public void Add(string methodName, Type type, Type[] paramTypes, string aliasName, HproseResultMode mode) {
            GlobalMethods.AddMethod(methodName, type, paramTypes, aliasName, mode);
        }

        public void Add(string methodName, object obj, Type[] paramTypes) {
            GlobalMethods.AddMethod(methodName, obj, paramTypes);
        }

        public void Add(string methodName, object obj, Type[] paramTypes, HproseResultMode mode) {
            GlobalMethods.AddMethod(methodName, obj, paramTypes, mode);
        }

        public void Add(string methodName, Type type, Type[] paramTypes) {
            GlobalMethods.AddMethod(methodName, type, paramTypes);
        }

        public void Add(string methodName, Type type, Type[] paramTypes, HproseResultMode mode) {
            GlobalMethods.AddMethod(methodName, type, paramTypes, mode);
        }

        public void Add(string methodName, object obj, string aliasName) {
            GlobalMethods.AddMethod(methodName, obj, aliasName);
        }

        public void Add(string methodName, object obj, string aliasName, HproseResultMode mode) {
            GlobalMethods.AddMethod(methodName, obj, aliasName, mode);
        }

        public void Add(string methodName, Type type, string aliasName) {
            GlobalMethods.AddMethod(methodName, type, aliasName);
        }

        public void Add(string methodName, Type type, string aliasName, HproseResultMode mode) {
            GlobalMethods.AddMethod(methodName, type, aliasName, mode);
        }

        public void Add(string methodName, object obj) {
            GlobalMethods.AddMethod(methodName, obj);
        }

        public void Add(string methodName, object obj, HproseResultMode mode) {
            GlobalMethods.AddMethod(methodName, obj, mode);
        }

        public void Add(string methodName, Type type) {
            GlobalMethods.AddMethod(methodName, type);
        }

        public void Add(string methodName, Type type, HproseResultMode mode) {
            GlobalMethods.AddMethod(methodName, type, mode);
        }

        public void Add(string[] methodNames, object obj, string[] aliasNames) {
            GlobalMethods.AddMethods(methodNames, obj, aliasNames);
        }

        public void Add(string[] methodNames, object obj, string[] aliasNames, HproseResultMode mode) {
            GlobalMethods.AddMethods(methodNames, obj, aliasNames, mode);
        }

        public void Add(string[] methodNames, object obj, string aliasPrefix) {
            GlobalMethods.AddMethods(methodNames, obj, aliasPrefix);
        }

        public void Add(string[] methodNames, object obj, string aliasPrefix, HproseResultMode mode) {
            GlobalMethods.AddMethods(methodNames, obj, aliasPrefix, mode);
        }

        public void Add(string[] methodNames, object obj) {
            GlobalMethods.AddMethods(methodNames, obj);
        }

        public void Add(string[] methodNames, object obj, HproseResultMode mode) {
            GlobalMethods.AddMethods(methodNames, obj, mode);
        }

        public void Add(string[] methodNames, Type type, string[] aliasNames) {
            GlobalMethods.AddMethods(methodNames, type, aliasNames);
        }

        public void Add(string[] methodNames, Type type, string[] aliasNames, HproseResultMode mode) {
            GlobalMethods.AddMethods(methodNames, type, aliasNames, mode);
        }

        public void Add(string[] methodNames, Type type, string aliasPrefix) {
            GlobalMethods.AddMethods(methodNames, type, aliasPrefix);
        }

        public void Add(string[] methodNames, Type type, string aliasPrefix, HproseResultMode mode) {
            GlobalMethods.AddMethods(methodNames, type, aliasPrefix, mode);
        }

        public void Add(string[] methodNames, Type type) {
            GlobalMethods.AddMethods(methodNames, type);
        }

        public void Add(string[] methodNames, Type type, HproseResultMode mode) {
            GlobalMethods.AddMethods(methodNames, type, mode);
        }

        public void Add(object obj, Type type, string aliasPrefix) {
            GlobalMethods.AddInstanceMethods(obj, type, aliasPrefix);
        }

        public void Add(object obj, Type type, string aliasPrefix, HproseResultMode mode) {
            GlobalMethods.AddInstanceMethods(obj, type, aliasPrefix, mode);
        }

        public void Add(object obj, Type type) {
            GlobalMethods.AddInstanceMethods(obj, type);
        }

        public void Add(object obj, Type type, HproseResultMode mode) {
            GlobalMethods.AddInstanceMethods(obj, type, mode);
        }

        public void Add(object obj, string aliasPrefix) {
            GlobalMethods.AddInstanceMethods(obj, aliasPrefix);
        }

        public void Add(object obj, string aliasPrefix, HproseResultMode mode) {
            GlobalMethods.AddInstanceMethods(obj, aliasPrefix, mode);
        }

        public void Add(object obj) {
            GlobalMethods.AddInstanceMethods(obj);
        }

        public void Add(object obj, HproseResultMode mode) {
            GlobalMethods.AddInstanceMethods(obj, mode);
        }

        public void Add(Type type, string aliasPrefix) {
            GlobalMethods.AddStaticMethods(type, aliasPrefix);
        }

        public void Add(Type type, string aliasPrefix, HproseResultMode mode) {
            GlobalMethods.AddStaticMethods(type, aliasPrefix, mode);
        }

        public void Add(Type type) {
            GlobalMethods.AddStaticMethods(type);
        }

        public void Add(Type type, HproseResultMode mode) {
            GlobalMethods.AddStaticMethods(type, mode);
        }

        public void AddMissingMethod(string methodName, object obj) {
            GlobalMethods.AddMissingMethod(methodName, obj);
        }

        public void AddMissingMethod(string methodName, object obj, HproseResultMode mode) {
            GlobalMethods.AddMissingMethod(methodName, obj, mode);
        }

        public void AddMissingMethod(string methodName, Type type) {
            GlobalMethods.AddMissingMethod(methodName, type);
        }

        public void AddMissingMethod(string methodName, Type type, HproseResultMode mode) {
            GlobalMethods.AddMissingMethod(methodName, type, mode);
        }

        protected abstract Stream OutputStream {
             get;
        }

        protected abstract Stream InputStream {
            get;
        }

        protected virtual void SendHeader() {
            if (OnSendHeader != null) {
                OnSendHeader();
            }
        }

        protected virtual object[] FixArguments(Type[] argumentTypes, object[] arguments, int count) {
            return arguments;
        }

        protected void SendError(string error) {
            if (OnSendError != null) {
                OnSendError(error);
            }
            Stream ostream = OutputStream;
            if (filter != null) ostream = filter.OutputFilter(ostream);
            HproseWriter writer = new HproseWriter(ostream, mode);
            ostream.WriteByte(HproseTags.TagError);
            writer.WriteString(error);
            ostream.WriteByte(HproseTags.TagEnd);
            ostream.Flush();
        }

        protected void DoInvoke(HproseMethods methods) {
            Stream istream = InputStream;
            if (filter != null) istream = filter.InputFilter(istream);
            HproseReader reader = new HproseReader(istream, mode);
            Stream ostream = OutputStream;
            if (filter != null) ostream = filter.OutputFilter(ostream);
            HproseWriter writer = new HproseWriter(ostream, mode);
            int tag;
            do {
                reader.Reset();
                string name = reader.ReadString();
                HproseMethod remoteMethod = null;
                int count = 0;
                object[] args = null;
                object[] arguments = null;
                bool byRef = false;
                tag = reader.CheckTags((char)HproseTags.TagList + "" +
                                       (char)HproseTags.TagEnd + "" +
                                       (char)HproseTags.TagCall);
                if (tag == HproseTags.TagList) {
                    reader.Reset();
                    count = reader.ReadInt(HproseTags.TagOpenbrace);
                    if (methods != null) {
                        remoteMethod = methods.GetMethod(name, count);
                    }
                    if (remoteMethod == null) {
                        remoteMethod = GlobalMethods.GetMethod(name, count);
                    }
                    if (remoteMethod == null) {
                        arguments = reader.ReadArray(count);
                    }
                    else {
                        arguments = new object[count];
                        reader.ReadArray(remoteMethod.paramTypes, arguments, count);
                    }
                    reader.CheckTag(HproseTags.TagClosebrace);
                    tag = reader.CheckTags((char)HproseTags.TagTrue + "" +
                                           (char)HproseTags.TagEnd + "" +
                                           (char)HproseTags.TagCall);
                    if (tag == HproseTags.TagTrue) {
                        byRef = true;
                        tag = reader.CheckTags((char)HproseTags.TagEnd + "" +
                                               (char)HproseTags.TagCall);
                    }
                }
                else {
                    if (methods != null) {
                        remoteMethod = methods.GetMethod(name, 0);
                    }
                    if (remoteMethod == null) {
                        remoteMethod = GlobalMethods.GetMethod(name, 0);
                    }
                    arguments = new object[0];
                }
                if (OnBeforeInvoke != null) {
                    OnBeforeInvoke(name, arguments, byRef);
                }
                if (remoteMethod == null) {
                    args = arguments;
                }
                else {
                    args = FixArguments(remoteMethod.paramTypes, arguments, count);
                }
                object result;
                if (remoteMethod == null) {
                    if (methods != null) {
                        remoteMethod = methods.GetMethod("*", 2);
                    }
                    if (remoteMethod == null) {
                        remoteMethod = GlobalMethods.GetMethod("*", 2);
                    }
                    if (remoteMethod == null) {
                        throw new MissingMethodException("Can't find this method " + name);
                    }
                    result = remoteMethod.method.Invoke(remoteMethod.obj, new object[] { name, args });
                }
                else {
                    result = remoteMethod.method.Invoke(remoteMethod.obj, args);
                }
                if (byRef) {
                    Array.Copy(args, 0, arguments, 0, count);
                }
                if (OnAfterInvoke != null) {
                    OnAfterInvoke(name, arguments, byRef, result);
                }
                if (remoteMethod.mode == HproseResultMode.RawWithEndTag) {
                    ostream.Write((byte[])result, 0, ((byte[])result).Length);
                    ostream.Flush();
                    return;
                }
                else if (remoteMethod.mode == HproseResultMode.Raw) {
                    ostream.Write((byte[])result, 0, ((byte[])result).Length);
                }
                else {
                    ostream.WriteByte(HproseTags.TagResult);
                    if (remoteMethod.mode == HproseResultMode.Serialized) {
                        ostream.Write((byte[])result, 0, ((byte[])result).Length);
                    }
                    else {
                        writer.Reset();
                        writer.Serialize(result);
                    }
                    if (byRef) {
                        ostream.WriteByte(HproseTags.TagArgument);
                        writer.Reset();
                        writer.WriteArray(arguments);
                    }
                }
            } while (tag == HproseTags.TagCall);
            ostream.WriteByte(HproseTags.TagEnd);
            ostream.Flush();
        }

        protected void DoFunctionList(HproseMethods methods) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
            List<string> names = new List<string>(GlobalMethods.AllNames);
#else
            ArrayList names = new ArrayList(GlobalMethods.AllNames);
#endif            
            if (methods != null) {
                names.AddRange(methods.AllNames);
            }
            Stream ostream = OutputStream;
            if (filter != null) ostream = filter.OutputFilter(ostream);
            HproseWriter writer = new HproseWriter(ostream, mode);
            ostream.WriteByte(HproseTags.TagFunctions);
#if !(dotNET10 || dotNET11 || dotNETCF10)
            writer.WriteList((IList<string>)names);
#else
            writer.WriteList((IList)names);
#endif
            ostream.WriteByte(HproseTags.TagEnd);
            ostream.Flush();
        }

        public virtual void Handle() {
            Handle(null);
        }

        public virtual void Handle(HproseMethods methods) {
            SendHeader();
            try {
                int tag = InputStream.ReadByte();
                switch (tag) {
                    case HproseTags.TagCall:
                        DoInvoke(methods);
                        break;
                    case HproseTags.TagEnd:
                        DoFunctionList(methods);
                        break;
                    default:
                        SendError("Unknown Tag");
                        break;
                }
            }
            catch (Exception e) {
                if (debugEnabled) {
                    SendError(e.ToString());
                }
                else {
                    SendError(e.Message);
                }
            }
        }
    }
}
#endif