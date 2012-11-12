#if (dotNET2 || dotNET35 || dotNETCF20 || dotNETCF35 || SL2 || SL3 || WP70 || WP71 || MONO2)
namespace System
{
#if (dotNET2 || dotNETCF20)
	public delegate TResult Func <TResult> ();
	public delegate TResult Func <T1, TResult> (T1 arg1);
	public delegate TResult Func <T1, T2, TResult> (T1 arg1, T2 arg2);
	public delegate TResult Func <T1, T2, T3, TResult> (T1 arg1, T2 arg2, T3 arg3);
	public delegate TResult Func <T1, T2, T3, T4, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4);
#endif
	public delegate TResult Func <T1, T2, T3, T4, T5, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, T9, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9, T10 arg10);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9, T10 arg10, T11 arg11);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9, T10 arg10, T11 arg11, T12 arg12);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9, T10 arg10, T11 arg11, T12 arg12, T13 arg13);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9, T10 arg10, T11 arg11, T12 arg12, T13 arg13, T14 arg14);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9, T10 arg10, T11 arg11, T12 arg12, T13 arg13, T14 arg14, T15 arg15);
	public delegate TResult Func <T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, TResult> (T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9, T10 arg10, T11 arg11, T12 arg12, T13 arg13, T14 arg14, T15 arg15, T16 arg16);
}
#endif