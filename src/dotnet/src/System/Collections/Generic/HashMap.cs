/* HashMap class.
 * This library is free. You can redistribute it and/or modify it.
 */
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System;
namespace System.Collections.Generic {
    public class HashMap<TKey, TValue>: IDictionary<TKey, TValue>, IDictionary,
        ICollection<KeyValuePair<TKey, TValue>>, ICollection,
        IEnumerable<KeyValuePair<TKey, TValue>>, IEnumerable {
        private Dictionary<TKey, TValue> dict;
        private TValue valueOfNullKey = default(TValue);
        private bool hasNullKey = false;
        public HashMap() {
            dict = new Dictionary<TKey, TValue>();
        }
        public HashMap(IDictionary<TKey, TValue> dictionary) {
            dict = new Dictionary<TKey, TValue>(dictionary);
        }
        public HashMap(IEqualityComparer<TKey> comparer) {
            dict = new Dictionary<TKey, TValue>(comparer);
        }
        public HashMap(int capacity) {
            dict = new Dictionary<TKey, TValue>(capacity);
        }
        public HashMap(IDictionary<TKey, TValue> dictionary, IEqualityComparer<TKey> comparer) {
            dict = new Dictionary<TKey, TValue>(dictionary, comparer);
        }
        public HashMap(int capacity, IEqualityComparer<TKey> comparer) {
            dict = new Dictionary<TKey, TValue>(capacity, comparer);
        }
        public IEqualityComparer<TKey> Comparer {
            get {
                return dict.Comparer;
            }
        }
        public int Count {
            get {
                return dict.Count + (hasNullKey ? 1 : 0);
            }
        }
        public TValue this[TKey key] {
            get {
                if (key == null) {
                    if (hasNullKey) return valueOfNullKey;
                    throw new KeyNotFoundException();
                }
                return dict[key];
            }
            set {
                if (key == null) {
                    valueOfNullKey = value;
                    hasNullKey = true;
                }
                else {
                    dict[key] = value;
                }
            }
        }
        public KeyCollection Keys {
            get {
                return new KeyCollection(this, dict.Keys);
            }
        }
        public ValueCollection Values {
            get {
                return new ValueCollection(this, dict.Values);
            }
        }
        public void Add(TKey key, TValue value) {
            if (key == null) {
                if (hasNullKey) throw new ArgumentException("An element with the same key already exists in the dictionary.");
                valueOfNullKey = value;
                hasNullKey = true;
            }
            else {
                dict.Add(key, value);
            }
        }
        public void Clear() {
            valueOfNullKey = default(TValue);
            hasNullKey = false;
            dict.Clear();
        }
        public bool ContainsKey(TKey key) {
            if (key == null) return hasNullKey;
            return dict.ContainsKey(key);
        }
        public bool ContainsValue(TValue value) {
            if (hasNullKey) {
                IEqualityComparer<TValue> cmp = EqualityComparer<TValue>.Default;
                if (cmp.Equals(valueOfNullKey, value)) return true;
            }
            return dict.ContainsValue(value);
        }
        public Enumerator GetEnumerator() {
            return new Enumerator(this, dict.GetEnumerator());
        }
        public bool Remove(TKey key) {
            if (key == null) {
                if (hasNullKey) {
                    valueOfNullKey = default(TValue);
                    hasNullKey = false;
                    return true;
                }
                return false;
            }
            else {
                return dict.Remove(key);
            }
        }
        public bool TryGetValue(TKey key, out TValue value) {
            if (key == null) {
                value = hasNullKey ? valueOfNullKey : default(TValue);
                return hasNullKey;
            }
            return dict.TryGetValue(key, out value);
        }
        void ICollection<KeyValuePair<TKey, TValue>>.Add(KeyValuePair<TKey, TValue> keyValuePair) {
            Add(keyValuePair.Key, keyValuePair.Value);
        }
        bool ICollection<KeyValuePair<TKey, TValue>>.Contains(KeyValuePair<TKey, TValue> keyValuePair) {
            TValue value;
            if (!TryGetValue(keyValuePair.Key, out value)) return false;
            return EqualityComparer<TValue>.Default.Equals(keyValuePair.Value, value);
        }
        private void CopyTo(KeyValuePair<TKey, TValue>[] array, int index) {
            if (hasNullKey) {
                ((ICollection<KeyValuePair<TKey, TValue>>)dict).CopyTo(array, index + 1);
                array[index] = new KeyValuePair<TKey, TValue>(default(TKey), valueOfNullKey);
            }
            else {
                ((ICollection<KeyValuePair<TKey, TValue>>)dict).CopyTo(array, index);
            }
        }
        void ICollection<KeyValuePair<TKey, TValue>>.CopyTo(KeyValuePair<TKey, TValue>[] array, int index) {
            CopyTo(array, index);
        }
        void ICollection.CopyTo(Array array, int index) {
            CopyTo((KeyValuePair<TKey, TValue>[])array, index);
        }
        bool ICollection<KeyValuePair<TKey, TValue>>.IsReadOnly {
            get {
                return false;
            }
        }
        bool ICollection.IsSynchronized {
            get {
                return false;
            }
        }
        bool ICollection<KeyValuePair<TKey, TValue>>.Remove(KeyValuePair<TKey, TValue> keyValuePair) {
            if (keyValuePair.Key == null) {
                if (hasNullKey) {
                    valueOfNullKey = default(TValue);
                    hasNullKey = false;
                    return true;
                }
                return false;
            }
            return ((ICollection<KeyValuePair<TKey, TValue>>)dict).Remove(keyValuePair);
        }
        object ICollection.SyncRoot {
            get {
                return ((ICollection)dict).SyncRoot;
            }
        }
        static T ToT<T>(object obj, string paramName) {
            if ((obj == null) && (default(T) != null) || !(obj is T)) {
                throw new ArgumentException ("not of type: " + typeof (T).ToString(), paramName);
            }
            return (T)obj;
        }
        void IDictionary.Add(object key, object value) {
            this.Add(ToT<TKey>(key, "key"), ToT<TValue>(value, "value"));
        }
        bool IDictionary.Contains(object key) {
            if (key == null) return hasNullKey;
            return ((IDictionary)dict).Contains(key);
        }
        IDictionaryEnumerator IDictionary.GetEnumerator() {
            return new HashMapEnumerator(this, ((IDictionary)dict).GetEnumerator());
        }
        bool IDictionary.IsFixedSize {
            get {
                return false;
            }
        }
        bool IDictionary.IsReadOnly {
            get {
                return false;
            }
        }
        object IDictionary.this[object key] {
            get {
                if (key == null) {
                    if (hasNullKey) return valueOfNullKey;
                }
                else {
                    TKey k = ToT<TKey>(key, "key");
                    if (ContainsKey(k)) return this[k];
                }
                return null;
            }
            set {
                this[ToT<TKey>(key, "key")] = ToT<TValue>(value, "value");
            }
        }
        ICollection<TKey> IDictionary<TKey, TValue>.Keys {
            get { return Keys; }
        }
        ICollection IDictionary.Keys {
            get { return Keys; }
        }
        void IDictionary.Remove(object key) {
            if (key == null) {
                valueOfNullKey = default(TValue);
                hasNullKey = false;
            }
            else {
                ((IDictionary)dict).Remove(key);
            }
        }
        ICollection<TValue> IDictionary<TKey, TValue>.Values {
            get { return Values; }
        }
        ICollection IDictionary.Values {
            get { return Values; }
        }
        IEnumerator<KeyValuePair<TKey, TValue>> IEnumerable<KeyValuePair<TKey, TValue>>.GetEnumerator() {
            return new Enumerator(this, dict.GetEnumerator());
        }
        IEnumerator IEnumerable.GetEnumerator() {
            return new Enumerator(this, dict.GetEnumerator());
        }

        public struct Enumerator: IEnumerator<KeyValuePair<TKey, TValue>>,
            IDisposable, IDictionaryEnumerator, IEnumerator {
            private Dictionary<TKey, TValue>.Enumerator e;
            private HashMap<TKey, TValue> m;
            private int p;

            internal Enumerator(HashMap<TKey, TValue> m, Dictionary<TKey, TValue>.Enumerator e) {
                this.m = m;
                this.e = e;
                this.p = -1;
            }
            public bool MoveNext() {
                if (++p > 0) return e.MoveNext();
                if (m.hasNullKey) return true;
                return e.MoveNext();
            }
            public KeyValuePair<TKey, TValue> Current {
                get {
                    if ((p == 0) && m.hasNullKey) {
                        return new KeyValuePair<TKey, TValue>(default(TKey), m.valueOfNullKey);
                    }
                    return e.Current;
                }
            }
            public void Dispose() {
            }
            object IEnumerator.Current {
                get {
                    if ((p == 0) && m.hasNullKey) {
                        return new KeyValuePair<TKey, TValue>(default(TKey), m.valueOfNullKey);
                    }
                    return ((IEnumerator)e).Current;
                }
            }
            void IEnumerator.Reset() {
                p = -1;
                ((IEnumerator)e).Reset();
            }
            DictionaryEntry IDictionaryEnumerator.Entry {
                get {
                    if (p == 0 && m.hasNullKey) {
                        return new DictionaryEntry(null, m.valueOfNullKey);
                    }
                    return ((IDictionaryEnumerator)e).Entry;
                }
            }
            object IDictionaryEnumerator.Key {
                get {
                    if (p == 0 && m.hasNullKey) {
                        return null;
                    }
                    return ((IDictionaryEnumerator)e).Key;
                }
            }
            object IDictionaryEnumerator.Value {
                get {
                    if (p == 0 && m.hasNullKey) {
                        return m.valueOfNullKey;
                    }
                    return ((IDictionaryEnumerator)e).Value;
                }
            }
        }

        public struct HashMapEnumerator: IDictionaryEnumerator, IEnumerator {
            private IDictionaryEnumerator e;
            private HashMap<TKey, TValue> m;
            private int p;

            internal HashMapEnumerator(HashMap<TKey, TValue> m, IDictionaryEnumerator e) {
                this.m = m;
                this.e = e;
                this.p = -1;
            }
            bool IEnumerator.MoveNext() {
                if (++p > 0) return ((IEnumerator)e).MoveNext();
                if (m.hasNullKey) return true;
                return ((IEnumerator)e).MoveNext();
            }
            object IEnumerator.Current {
                get {
                    if (p == 0 && m.hasNullKey) {
                        return new DictionaryEntry(null, m.valueOfNullKey);
                    }
                    return e.Current;
                }
            }
            void IEnumerator.Reset() {
                p = -1;
                ((IEnumerator)e).Reset();
            }
            DictionaryEntry IDictionaryEnumerator.Entry {
                get {
                    if (p == 0 && m.hasNullKey) {
                        return new DictionaryEntry(null, m.valueOfNullKey);
                    }
                    return e.Entry;
                }
            }
            object IDictionaryEnumerator.Key {
                get {
                    if (p == 0 && m.hasNullKey) {
                        return null;
                    }
                    return e.Key;
                }
            }
            object IDictionaryEnumerator.Value {
                get {
                    if (p == 0 && m.hasNullKey) {
                        return m.valueOfNullKey;
                    }
                    return e.Value;
                }
            }
        }

        public sealed class KeyCollection: ICollection<TKey>, IEnumerable<TKey>, ICollection, IEnumerable {
            private HashMap<TKey, TValue> m;
            private Dictionary<TKey, TValue>.KeyCollection keys;

            internal KeyCollection(HashMap<TKey, TValue> m, Dictionary<TKey, TValue>.KeyCollection keys) {
                this.m = m;
                this.keys = keys;
            }
            public void CopyTo(TKey[] array, int index) {
                if (m.hasNullKey) {
                    keys.CopyTo(array, index + 1);
                    array[index] = default(TKey);
                }
                else {
                    keys.CopyTo(array, index);
                }
            }
            public Enumerator GetEnumerator() {
                return new Enumerator(m, keys.GetEnumerator());
            }
            void ICollection<TKey>.Add(TKey item) {
                ((ICollection<TKey>)keys).Add(item);
            }
            void ICollection<TKey>.Clear() {
                ((ICollection<TKey>)keys).Clear();
            }
            bool ICollection<TKey>.Contains(TKey item) {
                if (item == null) return m.hasNullKey;
                return ((ICollection<TKey>)keys).Contains(item);
            }
            bool ICollection<TKey>.Remove(TKey item) {
                return ((ICollection<TKey>)keys).Remove(item);
            }
            IEnumerator<TKey> IEnumerable<TKey>.GetEnumerator() {
                return new Enumerator(m, keys.GetEnumerator());
            }
            void ICollection.CopyTo(Array array, int index) {
                if (m.hasNullKey) {
                    ((ICollection)keys).CopyTo(array, index + 1);
                    array.SetValue(null, index);
                }
                else {
                    ((ICollection)keys).CopyTo(array, index);
                }
            }
            IEnumerator IEnumerable.GetEnumerator() {
                return new Enumerator(m, keys.GetEnumerator());
            }
            public int Count {
                get {
                    return keys.Count + (m.hasNullKey ? 1 : 0);
                }
            }
            bool ICollection<TKey>.IsReadOnly {
                get {
                    return true;
                }
            }
            bool ICollection.IsSynchronized {
                get {
                    return false;
                }
            }
            object ICollection.SyncRoot {
                get {
                    return ((ICollection)keys).SyncRoot;
                }
            }
            public struct Enumerator: IEnumerator<TKey>, IDisposable, IEnumerator {
                private HashMap<TKey, TValue> m;
                private Dictionary<TKey, TValue>.KeyCollection.Enumerator e;
                private int p;
                internal Enumerator(HashMap<TKey, TValue> m, Dictionary<TKey, TValue>.KeyCollection.Enumerator e) {
                    this.m = m;
                    this.e = e;
                    this.p = -1;
                }
                public void Dispose() {
                }
                public bool MoveNext() {
                    if (++p > 0) return e.MoveNext();
                    if (m.hasNullKey) return true;
                    return e.MoveNext();
                }
                public TKey Current {
                    get {
                        if ((p == 0) && m.hasNullKey) {
                            return default(TKey);
                        }
                        return e.Current;
                    }
                }
                object IEnumerator.Current {
                    get {
                        if ((p == 0) && m.hasNullKey) {
                            return null;
                        }
                        return ((IEnumerator)e).Current;
                    }
                }
                void IEnumerator.Reset() {
                    p = -1;
                    ((IEnumerator)e).Reset();
                }
            }
        }
        public sealed class ValueCollection: ICollection<TValue>, IEnumerable<TValue>, ICollection, IEnumerable {
            private HashMap<TKey, TValue> m;
            private Dictionary<TKey, TValue>.ValueCollection values;

            internal ValueCollection(HashMap<TKey, TValue> m, Dictionary<TKey, TValue>.ValueCollection values) {
                this.m = m;
                this.values = values;
            }
            public void CopyTo(TValue[] array, int index) {
                if (m.hasNullKey) {
                    values.CopyTo(array, index + 1);
                    array[index] = m.valueOfNullKey;
                }
                else {
                    values.CopyTo(array, index);
                }
            }
            public Enumerator GetEnumerator() {
                return new Enumerator(m, values.GetEnumerator());
            }
            void ICollection<TValue>.Add(TValue item) {
                ((ICollection<TValue>)values).Add(item);
            }
            void ICollection<TValue>.Clear() {
                ((ICollection<TValue>)values).Clear();
            }
            bool ICollection<TValue>.Contains(TValue item) {
                if (m.hasNullKey) {
                    IEqualityComparer<TValue> cmp = EqualityComparer<TValue>.Default;
                    if (cmp.Equals(m.valueOfNullKey, item)) return true;
                }
                return ((ICollection<TValue>)values).Contains(item);
            }
            bool ICollection<TValue>.Remove(TValue item) {
                return ((ICollection<TValue>)values).Remove(item);
            }
            IEnumerator<TValue> IEnumerable<TValue>.GetEnumerator() {
                return new Enumerator(m, values.GetEnumerator());
            }
            void ICollection.CopyTo(Array array, int index) {
                if (m.hasNullKey) {
                    ((ICollection)values).CopyTo(array, index + 1);
                    array.SetValue(m.valueOfNullKey, index);
                }
                else {
                    ((ICollection)values).CopyTo(array, index);
                }
            }
            IEnumerator IEnumerable.GetEnumerator() {
                return new Enumerator(m, values.GetEnumerator());
            }
            public int Count {
                get {
                    return values.Count + (m.hasNullKey ? 1 : 0);
                }
            }
            bool ICollection<TValue>.IsReadOnly {
                get {
                    return true;
                }
            }
            bool ICollection.IsSynchronized {
                get {
                    return false;
                }
            }
            object ICollection.SyncRoot {
                get {
                    return ((ICollection)values).SyncRoot;
                }
            }
            public struct Enumerator: IEnumerator<TValue>, IDisposable, IEnumerator {
                private HashMap<TKey, TValue> m;
                private Dictionary<TKey, TValue>.ValueCollection.Enumerator e;
                private int p;
                internal Enumerator(HashMap<TKey, TValue> m, Dictionary<TKey, TValue>.ValueCollection.Enumerator e) {
                    this.m = m;
                    this.e = e;
                    this.p = -1;
                }
                public void Dispose() {
                }
                public bool MoveNext() {
                    if (++p > 0) return e.MoveNext();
                    if (m.hasNullKey) return true;
                    return e.MoveNext();
                }
                public TValue Current {
                    get {
                        if ((p == 0) && m.hasNullKey) {
                            return m.valueOfNullKey;
                        }
                        return e.Current;
                    }
                }
                object IEnumerator.Current {
                    get {
                        if ((p == 0) && m.hasNullKey) {
                            return m.valueOfNullKey;
                        }
                        return ((IEnumerator)e).Current;
                    }
                }
                void IEnumerator.Reset() {
                    p = -1;
                    ((IEnumerator)e).Reset();
                }
            }
        }
    }
}
#endif