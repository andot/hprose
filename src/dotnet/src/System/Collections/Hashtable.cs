/* Hashtable class.
 * This library is free. You can redistribute it and/or modify it.
 */

#if SILVERLIGHT
namespace System.Collections {
    using System;
    using System.Runtime.InteropServices;
    using System.Threading;

    internal static class HashHelpers {
        internal static readonly int[] primes = new int[] { 
            3, 7, 11, 0x11, 0x17, 0x1d, 0x25, 0x2f, 0x3b, 0x47, 0x59, 0x6b, 0x83, 0xa3, 0xc5, 0xef, 
            0x125, 0x161, 0x1af, 0x209, 0x277, 0x2f9, 0x397, 0x44f, 0x52f, 0x63d, 0x78b, 0x91d, 0xaf1, 0xd2b, 0xfd1, 0x12fd, 
            0x16cf, 0x1b65, 0x20e3, 0x2777, 0x2f6f, 0x38ff, 0x446f, 0x521f, 0x628d, 0x7655, 0x8e01, 0xaa6b, 0xcc89, 0xf583, 0x126a7, 0x1619b, 
            0x1a857, 0x1fd3b, 0x26315, 0x2dd67, 0x3701b, 0x42023, 0x4f361, 0x5f0ed, 0x72125, 0x88e31, 0xa443b, 0xc51eb, 0xec8c1, 0x11bdbf, 0x154a3f, 0x198c4f, 
            0x1ea867, 0x24ca19, 0x2c25c1, 0x34fa1b, 0x3f928f, 0x4c4987, 0x5b8b6f, 0x6dda89
         };


        internal static int GetPrime(int min) {
            if (min < 0) {
                throw new ArgumentException("Hashtable's capacity overflowed and went negative. Check load factor, capacity and the current size of the table.");
            }
            for (int i = 0; i < primes.Length; i++) {
                int num2 = primes[i];
                if (num2 >= min) {
                    return num2;
                }
            }
            for (int j = min | 1; j < 0x7fffffff; j += 2) {
                if (IsPrime(j)) {
                    return j;
                }
            }
            return min;
        }

        internal static bool IsPrime(int candidate) {
            if ((candidate & 1) == 0) {
                return (candidate == 2);
            }
            int num = (int)Math.Sqrt((double)candidate);
            for (int i = 3; i <= num; i += 2) {
                if ((candidate % i) == 0) {
                    return false;
                }
            }
            return true;
        }
    }

    public class Hashtable : IDictionary, ICollection, IEnumerable {
        private IEqualityComparer _keycomparer;
        private object _syncRoot;
        private bucket[] buckets;
        private const string ComparerName = "Comparer";
        private int count;
        private const string HashCodeProviderName = "HashCodeProvider";
        private const string HashSizeName = "HashSize";
        private const int InitialSize = 3;
        private volatile bool isWriterInProgress;
        private const string KeyComparerName = "KeyComparer";
        private ICollection keys;
        private const string KeysName = "Keys";
        private float loadFactor;
        private const string LoadFactorName = "LoadFactor";
        private int loadsize;
        private int occupancy;
        private ICollection values;
        private const string ValuesName = "Values";
        private volatile int version;
        private const string VersionName = "Version";

        public Hashtable()
            : this(0, (float)1f) {
        }

        internal Hashtable(bool trash) {
        }

        public Hashtable(IDictionary d)
            : this(d, (float)1f) {
        }

        public Hashtable(IDictionary d, IEqualityComparer equalityComparer)
            : this(d, (float)1f, equalityComparer) {
        }

        public Hashtable(IDictionary d, float loadFactor)
            : this(d, loadFactor, (IEqualityComparer)null) {
        }

        public Hashtable(IDictionary d, float loadFactor, IEqualityComparer equalityComparer)
            : this((d != null) ? d.Count : 0, loadFactor, equalityComparer) {
            if (d == null) {
                throw new ArgumentNullException("d", "Dictionary cannot be null.");
            }
            IDictionaryEnumerator enumerator = d.GetEnumerator();
            while (enumerator.MoveNext()) {
                this.Add(enumerator.Key, enumerator.Value);
            }
        }

        public Hashtable(IEqualityComparer equalityComparer)
            : this(0, 1f, equalityComparer) {
        }

        public Hashtable(int capacity)
            : this(capacity, (float)1f) {
        }

        public Hashtable(int capacity, IEqualityComparer equalityComparer)
            : this(capacity, 1f, equalityComparer) {
        }

        public Hashtable(int capacity, float loadFactor) {
            if (capacity < 0) {
                throw new ArgumentOutOfRangeException("capacity", "Non-negative number required.");
            }
            if ((loadFactor < 0.1f) || (loadFactor > 1f)) {
                throw new ArgumentOutOfRangeException("loadFactor", "Load factor needs to be between 0.1 and 1.0.");
            }
            this.loadFactor = 0.72f * loadFactor;
            double num = ((float)capacity) / this.loadFactor;
            if (num > 2147483647.0) {
                throw new ArgumentException("Hashtable's capacity overflowed and went negative. Check load factor, capacity and the current size of the table.");
            }
            int num2 = (num > 3.0) ? HashHelpers.GetPrime((int)num) : 3;
            this.buckets = new bucket[num2];
            this.loadsize = (int)(this.loadFactor * num2);
            this.isWriterInProgress = false;
        }

        public Hashtable(int capacity, float loadFactor, IEqualityComparer equalityComparer)
            : this(capacity, loadFactor) {
            this._keycomparer = equalityComparer;
        }

        public virtual void Add(object key, object value) {
            this.Insert(key, value, true);
        }


        public virtual void Clear() {
            if ((this.count != 0) || (this.occupancy != 0)) {
                this.isWriterInProgress = true;
                for (int i = 0; i < this.buckets.Length; i++) {
                    this.buckets[i].hash_coll = 0;
                    this.buckets[i].key = null;
                    this.buckets[i].val = null;
                }
                this.count = 0;
                this.occupancy = 0;
                this.UpdateVersion();
                this.isWriterInProgress = false;
            }
        }

        public virtual object Clone() {
            bucket[] buckets = this.buckets;
            Hashtable hashtable = new Hashtable(this.count, this._keycomparer);
            hashtable.version = this.version;
            hashtable.loadFactor = this.loadFactor;
            hashtable.count = 0;
            int length = buckets.Length;
            while (length > 0) {
                length--;
                object key = buckets[length].key;
                if ((key != null) && (key != buckets)) {
                    hashtable[key] = buckets[length].val;
                }
            }
            return hashtable;
        }

        public virtual bool Contains(object key) {
            return this.ContainsKey(key);
        }

        public virtual bool ContainsKey(object key) {
            uint num;
            uint num2;
            Hashtable.bucket bucket;
            if (key == null) {
                throw new ArgumentNullException("key", "Key cannot be null.");
            }
            Hashtable.bucket[] buckets = this.buckets;
            uint num3 = this.InitHash(key, buckets.Length, out num, out num2);
            int num4 = 0;
            int index = (int)(num % buckets.Length);
            do {
                bucket = buckets[index];
                if (bucket.key == null) {
                    return false;
                }
                if (((bucket.hash_coll & 0x7fffffff) == num3) && this.KeyEquals(bucket.key, key)) {
                    return true;
                }
                index = (int)(((ulong)index + (ulong)num2) % ((ulong)buckets.Length));
            }
            while ((bucket.hash_coll < 0) && (++num4 < buckets.Length));
            return false;
        }

        public virtual bool ContainsValue(object value) {
            if (value == null) {
                int length = this.buckets.Length;
                while (--length >= 0) {
                    if (((this.buckets[length].key != null) &&
                         (this.buckets[length].key != this.buckets)) &&
                        (this.buckets[length].val == null)) {
                        return true;
                    }
                }
            }
            else {
                int index = this.buckets.Length;
                while (--index >= 0) {
                    object val = this.buckets[index].val;
                    if ((val != null) && val.Equals(value)) {
                        return true;
                    }
                }
            }
            return false;
        }

        private void CopyEntries(Array array, int arrayIndex) {
            bucket[] buckets = this.buckets;
            int length = buckets.Length;
            while (--length >= 0) {
                object key = buckets[length].key;
                if ((key != null) && (key != this.buckets)) {
                    DictionaryEntry entry = new DictionaryEntry(key, buckets[length].val);
                    array.SetValue(entry, arrayIndex++);
                }
            }
        }

        private void CopyKeys(Array array, int arrayIndex) {
            bucket[] buckets = this.buckets;
            int length = buckets.Length;
            while (--length >= 0) {
                object key = buckets[length].key;
                if ((key != null) && (key != this.buckets)) {
                    array.SetValue(key, arrayIndex++);
                }
            }
        }

        public virtual void CopyTo(Array array, int arrayIndex) {
            if (array == null) {
                throw new ArgumentNullException("array", "Array cannot be null.");
            }
            if (array.Rank != 1) {
                throw new ArgumentException("Only single dimensional arrays are supported for the requested action.");
            }
            if (arrayIndex < 0) {
                throw new ArgumentOutOfRangeException("arrayIndex", "Non-negative number required.");
            }
            if ((array.Length - arrayIndex) < this.Count) {
                throw new ArgumentException("Destination array is not long enough to copy all the items in the collection. Check array index and length.");
            }
            this.CopyEntries(array, arrayIndex);
        }

        private void CopyValues(Array array, int arrayIndex) {
            bucket[] buckets = this.buckets;
            int length = buckets.Length;
            while (--length >= 0) {
                object key = buckets[length].key;
                if ((key != null) && (key != this.buckets)) {
                    array.SetValue(buckets[length].val, arrayIndex++);
                }
            }
        }

        private void expand() {
            int prime = HashHelpers.GetPrime(this.buckets.Length * 2);
            this.rehash(prime);
        }

        public virtual IDictionaryEnumerator GetEnumerator() {
            return new HashtableEnumerator(this, 3);
        }

        protected virtual int GetHash(object key) {
            if (this._keycomparer != null) {
                return this._keycomparer.GetHashCode(key);
            }
            return key.GetHashCode();
        }

        private uint InitHash(object key, int hashsize, out uint seed, out uint incr) {
            uint num = (uint)(this.GetHash(key) & 0x7fffffff);
            seed = num;
            incr = 1 + ((uint)(((seed >> 5) + 1) % (hashsize - 1)));
            return num;
        }

        private void Insert(object key, object nvalue, bool add) {
            uint num;
            uint num2;
            if (key == null) {
                throw new ArgumentNullException("key", "Key cannot be null.");
            }
            if (this.count >= this.loadsize) {
                this.expand();
            }
            else if ((this.occupancy > this.loadsize) && (this.count > 100)) {
                this.rehash();
            }
            uint num3 = this.InitHash(key, this.buckets.Length, out num, out num2);
            int num4 = 0;
            int index = -1;
            int num6 = (int)(num % this.buckets.Length);
        Label_0071:
            if (((index == -1) && (this.buckets[num6].key == this.buckets)) && (this.buckets[num6].hash_coll < 0)) {
                index = num6;
            }
            if ((this.buckets[num6].key == null) || ((this.buckets[num6].key == this.buckets) && ((this.buckets[num6].hash_coll & 0x80000000L) == 0L))) {
                if (index != -1) {
                    num6 = index;
                }
                this.isWriterInProgress = true;
                this.buckets[num6].val = nvalue;
                this.buckets[num6].key = key;
                this.buckets[num6].hash_coll |= (int)num3;
                this.count++;
                this.UpdateVersion();
                this.isWriterInProgress = false;
            }
            else if (((this.buckets[num6].hash_coll & 0x7fffffff) == num3) && this.KeyEquals(this.buckets[num6].key, key)) {
                if (add) {
                    throw new ArgumentException(string.Format("Item has already been added. Key in dictionary: '{0}'  Key being added: '{1}'", new object[] { this.buckets[num6].key, key }));
                }
                this.isWriterInProgress = true;
                this.buckets[num6].val = nvalue;
                this.UpdateVersion();
                this.isWriterInProgress = false;
            }
            else {
                if ((index == -1) && (this.buckets[num6].hash_coll >= 0)) {
                    this.buckets[num6].hash_coll |= -2147483648;
                    this.occupancy++;
                }
                num6 = (int)(((ulong)num6 + (ulong)num2) % ((ulong)this.buckets.Length));
                if (++num4 < this.buckets.Length) {
                    goto Label_0071;
                }
                if (index == -1) {
                    throw new InvalidOperationException("Hashtable insert failed. Load factor too high. The most common cause is multiple threads writing to the Hashtable simultaneously.");
                }
                this.isWriterInProgress = true;
                this.buckets[index].val = nvalue;
                this.buckets[index].key = key;
                this.buckets[index].hash_coll |= (int)num3;
                this.count++;
                this.UpdateVersion();
                this.isWriterInProgress = false;
            }
        }

        protected virtual bool KeyEquals(object item, object key) {
            if (object.ReferenceEquals(this.buckets, item)) {
                return false;
            }
            if (object.ReferenceEquals(item, key)) {
                return true;
            }
            if (this._keycomparer != null) {
                return this._keycomparer.Equals(item, key);
            }
            return ((item != null) && item.Equals(key));
        }

        private void putEntry(bucket[] newBuckets, object key, object nvalue, int hashcode) {
            uint num = (uint)hashcode;
            uint num2 = (uint)(1 + (((num >> 5) + 1) % (newBuckets.Length - 1)));
            int index = (int)(num % newBuckets.Length);
        Label_0017:
            if ((newBuckets[index].key == null) || (newBuckets[index].key == this.buckets)) {
                newBuckets[index].val = nvalue;
                newBuckets[index].key = key;
                newBuckets[index].hash_coll |= hashcode;
            }
            else {
                if (newBuckets[index].hash_coll >= 0) {
                    newBuckets[index].hash_coll |= -2147483648;
                    this.occupancy++;
                }
                index = (int)(((ulong)index + (ulong)num2) % ((ulong)newBuckets.Length));
                goto Label_0017;
            }
        }

        private void rehash() {
            this.rehash(this.buckets.Length);
        }

        private void rehash(int newsize) {
            this.occupancy = 0;
            Hashtable.bucket[] newBuckets = new Hashtable.bucket[newsize];
            for (int i = 0; i < this.buckets.Length; i++) {
                Hashtable.bucket bucket = this.buckets[i];
                if ((bucket.key != null) && (bucket.key != this.buckets)) {
                    this.putEntry(newBuckets, bucket.key, bucket.val, bucket.hash_coll & 0x7fffffff);
                }
            }
            this.isWriterInProgress = true;
            this.buckets = newBuckets;
            this.loadsize = (int)(this.loadFactor * newsize);
            this.UpdateVersion();
            this.isWriterInProgress = false;
        }

        public virtual void Remove(object key) {
            uint num;
            uint num2;
            Hashtable.bucket bucket;
            if (key == null) {
                throw new ArgumentNullException("key", "Key cannot be null.");
            }
            uint num3 = this.InitHash(key, this.buckets.Length, out num, out num2);
            int num4 = 0;
            int index = (int)(num % this.buckets.Length);
        Label_003A:
            bucket = this.buckets[index];
            if (((bucket.hash_coll & 0x7fffffff) == num3) && this.KeyEquals(bucket.key, key)) {
                this.isWriterInProgress = true;
                this.buckets[index].hash_coll &= -2147483648;
                if (this.buckets[index].hash_coll != 0) {
                    this.buckets[index].key = this.buckets;
                }
                else {
                    this.buckets[index].key = null;
                }
                this.buckets[index].val = null;
                this.count--;
                this.UpdateVersion();
                this.isWriterInProgress = false;
            }
            else {
                index = (int)(((ulong)index + (ulong)num2) % ((ulong)this.buckets.Length));
                if ((bucket.hash_coll < 0) && (++num4 < this.buckets.Length)) {
                    goto Label_003A;
                }
            }
        }

        public static Hashtable Synchronized(Hashtable table) {
            if (table == null) {
                throw new ArgumentNullException("table");
            }
            return new SyncHashtable(table);
        }

        IEnumerator IEnumerable.GetEnumerator() {
            return new HashtableEnumerator(this, 3);
        }

        private void UpdateVersion() {
            this.version++;
        }

        public virtual int Count {
            get {
                return this.count;
            }
        }

        public virtual bool IsFixedSize {
            get {
                return false;
            }
        }

        public virtual bool IsReadOnly {
            get {
                return false;
            }
        }

        public virtual bool IsSynchronized {
            get {
                return false;
            }
        }

        public virtual object this[object key] {
            get {
                uint num;
                uint num2;
                Hashtable.bucket bucket;
                int version;
                int num7;
                if (key == null) {
                    throw new ArgumentNullException("key", "Key cannot be null.");
                }
                Hashtable.bucket[] buckets = this.buckets;
                uint num3 = this.InitHash(key, buckets.Length, out num, out num2);
                int num4 = 0;
                int index = (int)(num % buckets.Length);
            Label_0038:
                num7 = 0;
                do {
                    version = this.version;
                    bucket = buckets[index];
                    if ((++num7 % 8) == 0) {
                        Thread.Sleep(1);
                    }
                }
                while (this.isWriterInProgress || (version != this.version));
                if (bucket.key != null) {
                    if (((bucket.hash_coll & 0x7fffffff) == num3) && this.KeyEquals(bucket.key, key)) {
                        return bucket.val;
                    }
                    index = (int)(((ulong)index + (ulong)num2) % ((ulong)buckets.Length));
                    if ((bucket.hash_coll < 0) && (++num4 < buckets.Length)) {
                        goto Label_0038;
                    }
                }
                return null;
            }
            set {
                this.Insert(key, value, false);
            }
        }

        public virtual ICollection Keys {
            get {
                if (this.keys == null) {
                    this.keys = new KeyCollection(this);
                }
                return this.keys;
            }
        }

        public virtual object SyncRoot {
            get {
                if (this._syncRoot == null) {
                    Interlocked.CompareExchange<object>(ref this._syncRoot, new object(), null);
                }
                return this._syncRoot;
            }
        }

        public virtual ICollection Values {
            get {
                if (this.values == null) {
                    this.values = new ValueCollection(this);
                }
                return this.values;
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct bucket {
            public object key;
            public object val;
            public int hash_coll;
        }

        private class HashtableEnumerator : IDictionaryEnumerator, IEnumerator {
            private int bucket;
            private bool current;
            private object currentKey;
            private object currentValue;
            internal const int DictEntry = 3;
            private int getObjectRetType;
            private Hashtable hashtable;
            internal const int Keys = 1;
            internal const int Values = 2;
            private int version;

            internal HashtableEnumerator(Hashtable hashtable, int getObjRetType) {
                this.hashtable = hashtable;
                this.bucket = hashtable.buckets.Length;
                this.version = hashtable.version;
                this.current = false;
                this.getObjectRetType = getObjRetType;
            }

            public object Clone() {
                return base.MemberwiseClone();
            }

            public virtual bool MoveNext() {
                if (this.version != this.hashtable.version) {
                    throw new InvalidOperationException("Collection was modified; enumeration operation may not execute.");
                }
                while (this.bucket > 0) {
                    this.bucket--;
                    object key = this.hashtable.buckets[this.bucket].key;
                    if ((key != null) && (key != this.hashtable.buckets)) {
                        this.currentKey = key;
                        this.currentValue = this.hashtable.buckets[this.bucket].val;
                        this.current = true;
                        return true;
                    }
                }
                this.current = false;
                return false;
            }

            public virtual void Reset() {
                if (this.version != this.hashtable.version) {
                    throw new InvalidOperationException("Collection was modified; enumeration operation may not execute.");
                }
                this.current = false;
                this.bucket = this.hashtable.buckets.Length;
                this.currentKey = null;
                this.currentValue = null;
            }

            public virtual object Current {
                get {
                    if (!this.current) {
                        throw new InvalidOperationException("Enumeration has either not started or has already finished.");
                    }
                    if (this.getObjectRetType == 1) {
                        return this.currentKey;
                    }
                    if (this.getObjectRetType == 2) {
                        return this.currentValue;
                    }
                    return new DictionaryEntry(this.currentKey, this.currentValue);
                }
            }

            public virtual DictionaryEntry Entry {
                get {
                    if (!this.current) {
                        throw new InvalidOperationException("Enumeration has either not started or has already finished.");
                    }
                    return new DictionaryEntry(this.currentKey, this.currentValue);
                }
            }

            public virtual object Key {
                get {
                    if (!this.current) {
                        throw new InvalidOperationException("Enumeration has not started. Call MoveNext.");
                    }
                    return this.currentKey;
                }
            }

            public virtual object Value {
                get {
                    if (!this.current) {
                        throw new InvalidOperationException("Enumeration has either not started or has already finished.");
                    }
                    return this.currentValue;
                }
            }
        }

        private class KeyCollection : ICollection, IEnumerable {
            private Hashtable _hashtable;

            internal KeyCollection(Hashtable hashtable) {
                this._hashtable = hashtable;
            }

            public virtual void CopyTo(Array array, int arrayIndex) {
                if (array == null) {
                    throw new ArgumentNullException("array");
                }
                if (array.Rank != 1) {
                    throw new ArgumentException("Only single dimensional arrays are supported for the requested action.");
                }
                if (arrayIndex < 0) {
                    throw new ArgumentOutOfRangeException("arrayIndex", "Non-negative number required.");
                }
                if ((array.Length - arrayIndex) < this._hashtable.count) {
                    throw new ArgumentException("Destination array is not long enough to copy all the items in the collection. Check array index and length.");
                }
                this._hashtable.CopyKeys(array, arrayIndex);
            }

            public virtual IEnumerator GetEnumerator() {
                return new Hashtable.HashtableEnumerator(this._hashtable, 1);
            }

            public virtual int Count {
                get {
                    return this._hashtable.count;
                }
            }

            public virtual bool IsSynchronized {
                get {
                    return this._hashtable.IsSynchronized;
                }
            }

            public virtual object SyncRoot {
                get {
                    return this._hashtable.SyncRoot;
                }
            }
        }

        private class SyncHashtable : Hashtable, IEnumerable {
            protected Hashtable _table;

            internal SyncHashtable(Hashtable table)
                : base(false) {
                this._table = table;
            }

            public override void Add(object key, object value) {
                lock (this._table.SyncRoot) {
                    this._table.Add(key, value);
                }
            }

            public override void Clear() {
                lock (this._table.SyncRoot) {
                    this._table.Clear();
                }
            }

            public override object Clone() {
                lock (this._table.SyncRoot) {
                    return Hashtable.Synchronized((Hashtable)this._table.Clone());
                }
            }

            public override bool Contains(object key) {
                return this._table.Contains(key);
            }

            public override bool ContainsKey(object key) {
                return this._table.ContainsKey(key);
            }

            public override void CopyTo(Array array, int arrayIndex) {
                lock (this._table.SyncRoot) {
                    this._table.CopyTo(array, arrayIndex);
                }
            }

            public override IDictionaryEnumerator GetEnumerator() {
                return this._table.GetEnumerator();
            }

            public override void Remove(object key) {
                lock (this._table.SyncRoot) {
                    this._table.Remove(key);
                }
            }

            IEnumerator IEnumerable.GetEnumerator() {
                return this._table.GetEnumerator();
            }

            public override int Count {
                get {
                    return this._table.Count;
                }
            }

            public override bool IsFixedSize {
                get {
                    return this._table.IsFixedSize;
                }
            }

            public override bool IsReadOnly {
                get {
                    return this._table.IsReadOnly;
                }
            }

            public override bool IsSynchronized {
                get {
                    return true;
                }
            }

            public override object this[object key] {
                get {
                    return this._table[key];
                }
                set {
                    lock (this._table.SyncRoot) {
                        this._table[key] = value;
                    }
                }
            }

            public override ICollection Keys {
                get {
                    lock (this._table.SyncRoot) {
                        return this._table.Keys;
                    }
                }
            }

            public override object SyncRoot {
                get {
                    return this._table.SyncRoot;
                }
            }

            public override ICollection Values {
                get {
                    lock (this._table.SyncRoot) {
                        return this._table.Values;
                    }
                }
            }
        }

        private class ValueCollection : ICollection, IEnumerable {
            private Hashtable _hashtable;

            internal ValueCollection(Hashtable hashtable) {
                this._hashtable = hashtable;
            }

            public virtual void CopyTo(Array array, int arrayIndex) {
                if (array == null) {
                    throw new ArgumentNullException("array");
                }
                if (array.Rank != 1) {
                    throw new ArgumentException("Only single dimensional arrays are supported for the requested action.");
                }
                if (arrayIndex < 0) {
                    throw new ArgumentOutOfRangeException("arrayIndex", "Non-negative number required.");
                }
                if ((array.Length - arrayIndex) < this._hashtable.count) {
                    throw new ArgumentException("Destination array is not long enough to copy all the items in the collection. Check array index and length.");
                }
                this._hashtable.CopyValues(array, arrayIndex);
            }

            public virtual IEnumerator GetEnumerator() {
                return new Hashtable.HashtableEnumerator(this._hashtable, 2);
            }

            public virtual int Count {
                get {
                    return this._hashtable.count;
                }
            }

            public virtual bool IsSynchronized {
                get {
                    return this._hashtable.IsSynchronized;
                }
            }

            public virtual object SyncRoot {
                get {
                    return this._hashtable.SyncRoot;
                }
            }
        }
    }
}
#endif