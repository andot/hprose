/* MissingMethodException class.
 * This library is free. You can redistribute it and/or modify it.
 */
#if Core

namespace System {
    public class MissingMethodException : MissingMemberException {
        public MissingMethodException() : base()  {
        }

        public MissingMethodException(string message) : base(message) {
        }

        public MissingMethodException(string message, Exception inner) : base(message, inner) {
        }
    }
}
#endif