/* Queue class.
 * This library is free. You can redistribute it and/or modify it.
 */

#if SILVERLIGHT
using System;
using System.Collections.Generic;

namespace System.Collections {
    public class Queue : Queue<object> {
        public Queue()
            : base() {
        }
        public Queue(int capacity)
            : base(capacity) {
        }
        public Queue(ICollection collection)
            : base((IEnumerable<object>)collection) {
        }
    }
}
#endif