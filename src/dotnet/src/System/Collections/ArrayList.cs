/* ArrayList class.
 * This library is free. You can redistribute it and/or modify it.
 */

#if SILVERLIGHT
using System;
using System.Collections;
using System.Collections.Generic;

namespace System.Collections {
    public class ArrayList: List<object> {
        public ArrayList() : base() {
        }
        public ArrayList(int capacity) : base(capacity) {
        }
        public ArrayList(ICollection collection) : base((IEnumerable<object>)collection) {
        }
        public void AddRange(ICollection c) {
            foreach (object o in c) Add(o);
        }
        public Array ToArray(Type type) {
            Array result = Array.CreateInstance(type, Count);
            Array.Copy(ToArray(), result, Count);
            return result;
        }
    }
}
#endif