/* Stack class.
 * This library is free. You can redistribute it and/or modify it.
 */

#if SILVERLIGHT
using System;
using System.Collections.Generic;

namespace System.Collections {
    public class Stack : Stack<object> {
        public Stack()
            : base() {
        }
        public Stack(int capacity)
            : base(capacity) {
        }
        public Stack(ICollection collection)
            : base((IEnumerable<object>)collection) {
        }
    }
}
#endif