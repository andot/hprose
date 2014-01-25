/* HashMap class.
 * This library is free. You can redistribute it and/or modify it.
 */
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
using System;
namespace System.Collections {
    public class HashMap: Hashtable, IDictionary, ICollection, IEnumerable, ICloneable {
        private object valueOfNullKey = null;
        private bool hasNullKey = false;
        public HashMap(): base() {
        }
        public HashMap(int capacity): base(capacity) {
        }
        public HashMap(int capacity, float loadFactor) : base(capacity, loadFactor) {
        }
        public HashMap(IDictionary value) : base(value) {
        }
        public override object Clone() {
            HashMap m = (HashMap)base.Clone();
            m.valueOfNullKey = valueOfNullKey;
            m.hasNullKey = hasNullKey;
            return m;
        }
        public override object this[object key] {
            get {
                if (key == null) return valueOfNullKey;
                return base[key];
            }
            set {
                if (key == null) {
                    valueOfNullKey = value;
                    hasNullKey = true;
                }
                else {
                    base[key] = value;
                }
            }
        }
        public override void Add(object key, object value) {
            if (key == null) {
                if (hasNullKey) return;
                valueOfNullKey = value;
                hasNullKey = true;
            }
            else {
                base.Add(key, value);
            }
        }
        public override bool Contains(object key) {
            return ContainsKey(key);
        }
        public override void CopyTo(Array array, int arrayIndex) {
            if (hasNullKey) {
                base.CopyTo(array, arrayIndex + 1);
                array.SetValue(new DictionaryEntry(null, valueOfNullKey), arrayIndex);
            }
            else {
                base.CopyTo(array, arrayIndex);
            }
        }
        public override bool ContainsKey(object key) {
            if (key == null) return hasNullKey;
            return base.ContainsKey(key);
        }
        public override bool ContainsValue(object value) {
            if (hasNullKey && (valueOfNullKey == value)) return true;
            return base.ContainsValue(value);
        }
        public override void Remove(object key) {
            if (key == null) {
                valueOfNullKey = null;
                hasNullKey = false;
            }
            else {
                base.Remove(key);
            }
        }
        public override int Count {
            get {
                return base.Count + (hasNullKey ? 1 : 0);
            }
        }
        public override void Clear() {
            valueOfNullKey = null;
            hasNullKey = false;
            base.Clear();
        }
        public override IDictionaryEnumerator GetEnumerator() {
            IDictionaryEnumerator e = base.GetEnumerator();
            if (hasNullKey) {
                return new HashMapEnumerator(e, valueOfNullKey, 3);
            }
            else {
                return e;
            }
        }
        IEnumerator IEnumerable.GetEnumerator() {
            IEnumerator e = base.GetEnumerator();
            if (hasNullKey) {
                return new HashMapEnumerator(e, valueOfNullKey, 3);
            }
            else {
                return e;
            }
        }
        public override ICollection Keys {
            get {
                return new KeysCollection(this, base.Keys);
            }
        }
        public override ICollection Values {
            get {
                return new ValuesCollection(this, base.Values);
            }
        }

        private class HashMapEnumerator: IDictionaryEnumerator, IEnumerator, ICloneable {
            private IEnumerator e;
            private object v;
            private int p;
            private int t;

            internal HashMapEnumerator(IEnumerator e, object v, int t) {
                this.e = e;
                this.v = v;
                this.t = t;
                this.p = -1;
            }
            private HashMapEnumerator(IEnumerator e, object v, int t, int p) {
                this.e = e;
                this.v = v;
                this.t = t;
                this.p = p;
            }
            public object Clone() {
                return new HashMapEnumerator(e, v, t, p);
            }
            public virtual bool MoveNext() {
                if (++p > 0) {
                    return e.MoveNext();
                }
                return true;
            }
            public virtual void Reset() {
                p = -1;
                e.Reset();
            }
            public virtual object Current {
                get {
                    if (p == 0) {
                        if (t == 1) {
                            return null;
                        }
                        if (t == 2) {
                            return v;
                        }
                        return new DictionaryEntry(null, v);
                    }
                    return e.Current;
                }
            }
            public virtual DictionaryEntry Entry {
                get {
                    if (p == 0) {
                        return new DictionaryEntry(null, v);
                    }
                    return (DictionaryEntry)e.Current;
                }
            }
            public virtual object Key {
                get {
                    if (p == 0) {
                        return null;
                    }
                    return ((IDictionaryEnumerator)e).Key;
                }
            }
            public virtual object Value {
                get {
                    if (p == 0) {
                        return v;
                    }
                    return ((IDictionaryEnumerator)e).Value;
                }
            }
        }

        private class KeysCollection : ICollection, IEnumerable {
            private HashMap m;
            private ICollection keys;

            internal KeysCollection(HashMap m, ICollection keys) {
                this.m = m;
                this.keys = keys;
            }
            public virtual void CopyTo(Array array, int arrayIndex) {
                if (m.hasNullKey) {
                    keys.CopyTo(array, arrayIndex + 1);
                    array.SetValue(null, arrayIndex);
                }
                else {
                    keys.CopyTo(array, arrayIndex);
                }
            }
            public virtual IEnumerator GetEnumerator() {
                IEnumerator e = keys.GetEnumerator();
                if (m.hasNullKey) {
                    return new HashMapEnumerator(e, m.valueOfNullKey, 1);
                }
                else {
                    return e;
                }
            }
            public virtual int Count {
                get {
                    return keys.Count + (m.hasNullKey ? 1 : 0);
                }
            }
            public virtual bool IsSynchronized {
                get {
                    return keys.IsSynchronized;
                }
            }
            public virtual object SyncRoot {
                get {
                    return keys.SyncRoot;
                }
            }
        }
        private class ValuesCollection : ICollection, IEnumerable {
            private HashMap m;
            private ICollection values;

            internal ValuesCollection(HashMap m, ICollection values) {
                this.m = m;
                this.values = values;
            }
            public virtual void CopyTo(Array array, int arrayIndex) {
                if (m.hasNullKey) {
                    values.CopyTo(array, arrayIndex + 1);
                    array.SetValue(m.valueOfNullKey, arrayIndex);
                }
                else {
                    values.CopyTo(array, arrayIndex);
                }
            }
            public virtual IEnumerator GetEnumerator() {
                IEnumerator e = values.GetEnumerator();
                if (m.hasNullKey) {
                    return new HashMapEnumerator(e, m.valueOfNullKey, 2);
                }
                else {
                    return e;
                }
            }
            public virtual int Count {
                get {
                    return values.Count + (m.hasNullKey ? 1 : 0);
                }
            }
            public virtual bool IsSynchronized {
                get {
                    return values.IsSynchronized;
                }
            }
            public virtual object SyncRoot {
                get {
                    return values.SyncRoot;
                }
            }
        }
    }
}
#endif