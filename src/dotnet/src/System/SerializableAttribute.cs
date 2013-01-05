/* SerializableAttribute class.
 * This library is free. You can redistribute it and/or modify it.
 */

#if (PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core) && !dotNETCF20 && !dotNETCF35
namespace System {
    using System.Runtime.InteropServices;

    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct
        | AttributeTargets.Enum | AttributeTargets.Delegate,
        Inherited = false, AllowMultiple = false)]
    public sealed class SerializableAttribute : Attribute {
    }
}
#endif