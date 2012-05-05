@echo off

if not exist bin mkdir bin
if not exist bin\1.0 mkdir bin\1.0
if not exist bin\1.1 mkdir bin\1.1
if not exist bin\2.0 mkdir bin\2.0
if not exist bin\2.0\x64 mkdir bin\2.0\x64
if not exist bin\3.5 mkdir bin\3.5
if not exist bin\3.5\x64 mkdir bin\3.5\x64
if not exist bin\4.0 mkdir bin\4.0
if not exist bin\4.0\x64 mkdir bin\4.0\x64
if not exist bin\WindowsPhone mkdir bin\WindowsPhone
if not exist bin\WindowsPhone71 mkdir bin\WindowsPhone71
if not exist bin\SilverLight2 mkdir bin\SilverLight2
if not exist bin\SilverLight3 mkdir bin\SilverLight3
if not exist bin\SilverLight4 mkdir bin\SilverLight4
if not exist bin\SilverLight5 mkdir bin\SilverLight5
if not exist bin\CF1.0 mkdir bin\CF1.0
if not exist bin\CF2.0 mkdir bin\CF2.0
if not exist bin\CF3.5 mkdir bin\CF3.5
if not exist bin\Mono mkdir bin\Mono
if not exist bin\Mono2 mkdir bin\Mono2

set SL2_PATH=C:\Program Files\Microsoft SDKs\Silverlight\v2.0\Reference Assemblies
set SL3_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v3.0
set SL4_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0
set SL5_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v5.0
set WP70_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0\Profile\WindowsPhone
set WP71_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0\Profile\WindowsPhone71
set CF_PATH=C:\Program Files\Microsoft.NET\SDK\CompactFramework
if DEFINED ProgramFiles(x86) set SL2_PATH=C:\Program Files (x86)\Microsoft SDKs\Silverlight\v2.0\Reference Assemblies
if DEFINED ProgramFiles(x86) set SL3_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v3.0
if DEFINED ProgramFiles(x86) set SL4_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0
if DEFINED ProgramFiles(x86) set SL5_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v5.0
if DEFINED ProgramFiles(x86) set WP70_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0\Profile\WindowsPhone
if DEFINED ProgramFiles(x86) set WP71_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0\Profile\WindowsPhone71
if DEFINED ProgramFiles(x86) set CF_PATH=C:\Program Files (x86)\Microsoft.NET\SDK\CompactFramework

set NUMERICS_SRC=
set NUMERICS_SRC=%NUMERICS_SRC% src\System\NotImplementedException.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\SerializableAttribute.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Runtime\Serialization\ISerializable.cs

set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\BigInteger.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\BigIntegerBuilder.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\BigNumber.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\NumericsHelpers.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\Complex.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\DoubleUlong.cs

set HPROSE_SRC=
set HPROSE_SRC=%HPROSE_SRC% src\System\Collections\ArrayList.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Collections\Hashtable.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Collections\HashMap.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Collections\Queue.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Collections\Stack.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\InvalidDataException.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\BlockType.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\CompressionMode.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\DecodeHelper.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\DeflateInput.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\Deflater.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\DeflateStream.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\DeflateStreamAsyncResult.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\FastEncoder.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\FastEncoderStatics.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\FastEncoderWindow.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\GZipDecoder.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\GZIPHeaderState.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\GZipStream.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\HuffmanTree.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\Inflater.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\InflaterState.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\InputBuffer.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\Match.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\MatchState.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\IO\Compression\OutputWindow.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Threading\ReaderWriterLock.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Threading\SynchronizationContext.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Windows\Forms\WindowsFormsSynchronizationContext.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\HproseException.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\HproseCallback.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\HproseInvocationHandler.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\HproseMethod.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\HproseMethods.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\IHproseInvoker.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\HproseResultMode.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Reflection\Proxy.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Reflection\IInvocationHandler.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Reflection\CtorAccessor.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Reflection\PropertyAccessor.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\ClassManager.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\ObjectSerializer.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\ObjectUnserializer.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\HproseFormatter.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\HproseHelper.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\HproseMode.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\HproseReader.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\HproseTags.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\HproseWriter.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Client\CookieManager.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Client\HproseClient.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Client\HproseHttpClient.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseService.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseServiceEvent.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpMethods.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpService.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpListenerMethods.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpListenerService.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpListenerServer.cs

set NUMERICS_REF= -reference:"bin\1.0\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\1.0\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\1.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\1.0\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v1.0.3705\Csc.exe -out:bin\1.0\System.Numerics.dll -define:dotNET10 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v1.0.3705\Csc.exe -out:bin\1.0\Hprose.dll -define:dotNET10 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v1.0.3705\Csc.exe -out:bin\1.0\Hprose.Client.dll -define:dotNET10;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set NUMERICS_REF= -reference:"bin\1.1\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\1.1\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\1.1\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\1.1\AssemblyInfo.cs
c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\1.1\System.Numerics.dll -define:dotNET11 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\1.1\Hprose.dll -define:dotNET11 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\1.1\Hprose.Client.dll -define:dotNET11;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set NUMERICS_REF= -reference:"bin\2.0\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\2.0\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\2.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\2.0\AssemblyInfo.cs
c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\2.0\System.Numerics.dll -define:dotNET2 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\2.0\Hprose.dll -define:dotNET2 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\2.0\Hprose.Client.dll -define:dotNET2;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set NUMERICS_REF= -reference:"bin\2.0\x64\System.Numerics.dll"
c:\WINDOWS\Microsoft.NET\Framework64\v2.0.50727\Csc.exe -out:bin\2.0\x64\System.Numerics.dll -define:dotNET2 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
c:\WINDOWS\Microsoft.NET\Framework64\v2.0.50727\Csc.exe -out:bin\2.0\x64\Hprose.dll -define:dotNET2 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
c:\WINDOWS\Microsoft.NET\Framework64\v2.0.50727\Csc.exe -out:bin\2.0\x64\Hprose.Client.dll -define:dotNET2;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set NUMERICS_REF= -reference:"bin\3.5\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\3.5\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\3.5\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\3.5\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\System.Numerics.dll -define:dotNET35 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\Hprose.dll -define:dotNET35 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\Hprose.Client.dll -define:dotNET35;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set NUMERICS_REF= -reference:"bin\3.5\x64\System.Numerics.dll"
C:\WINDOWS\Microsoft.NET\Framework64\v3.5\Csc.exe -out:bin\3.5\x64\System.Numerics.dll -define:dotNET35 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework64\v3.5\Csc.exe -out:bin\3.5\x64\Hprose.dll -define:dotNET35 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
C:\WINDOWS\Microsoft.NET\Framework64\v3.5\Csc.exe -out:bin\3.5\x64\Hprose.Client.dll -define:dotNET35;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set NUMERICS_REF= -reference:"C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\System.Numerics.dll"
set HPROSE_INFO= src\AssemblyInfo\Hprose\4.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\4.0\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.0\Hprose.dll -define:dotNET4 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.0\Hprose.Client.dll -define:dotNET4;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
set NUMERICS_REF= -reference:"C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\System.Numerics.dll"
C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Csc.exe -out:bin\4.0\x64\Hprose.dll -define:dotNET4 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Csc.exe -out:bin\4.0\x64\Hprose.Client.dll -define:dotNET4;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\system.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\System.Net.dll"

set NUMERICS_REF= -reference:"bin\SilverLight2\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\SilverLight2\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\SilverLight2\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\SilverLight2\System.Numerics.dll -define:SILVERLIGHT;SL2;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\SilverLight2\Hprose.Client.dll -define:SILVERLIGHT;SL2;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\system.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\System.Net.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\System.Windows.dll"

set NUMERICS_REF= -reference:"bin\SilverLight3\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\SilverLight3\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\SilverLight3\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\SilverLight3\System.Numerics.dll -define:SILVERLIGHT;SL3;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\SilverLight3\Hprose.Client.dll -define:SILVERLIGHT;SL3;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\system.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\System.Net.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\System.Windows.dll"

set NUMERICS_REF= -reference:"bin\SilverLight4\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\SilverLight4\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\SilverLight4\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\SilverLight4\System.Numerics.dll -define:SILVERLIGHT;SL4;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\SilverLight4\Hprose.Client.dll -define:SILVERLIGHT;SL4;ClientOnly -filealign:512 -target:library -noconfig -nowarn:1685 -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\system.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\System.Net.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\System.Windows.dll"

set NUMERICS_REF= -reference:"bin\SilverLight5\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\SilverLight5\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\SilverLight5\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\SilverLight5\System.Numerics.dll -define:SILVERLIGHT;SL5;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\SilverLight5\Hprose.Client.dll -define:SILVERLIGHT;SL5;ClientOnly -filealign:512 -target:library -noconfig -nowarn:1685 -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set WP_REFERENCE=
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\mscorlib.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\System.Core.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\system.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\System.Net.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\System.Windows.dll"

set NUMERICS_REF= -reference:"bin\WindowsPhone\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\WindowsPhone\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\WindowsPhone\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\WindowsPhone\System.Numerics.dll -define:SILVERLIGHT;SL4;WINDOWS_PHONE;WP70;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\WindowsPhone\Hprose.Client.dll -define:SILVERLIGHT;SL4;WINDOWS_PHONE;WP70;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set WP_REFERENCE=
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\mscorlib.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\System.Core.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\system.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\System.Net.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\System.Windows.dll"

set NUMERICS_REF= -reference:"bin\WindowsPhone71\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\WindowsPhone71\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\WindowsPhone71\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\WindowsPhone71\System.Numerics.dll -define:SILVERLIGHT;SL4;WINDOWS_PHONE;WP71;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\WindowsPhone71\Hprose.Client.dll -define:SILVERLIGHT;SL4;WINDOWS_PHONE;WP71;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v1.0\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v1.0\WindowsCE\System.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v1.0\WindowsCE\System.Windows.Forms.dll"

set NUMERICS_REF= -reference:"bin\CF1.0\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\CF1.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\CF1.0\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\CF1.0\System.Numerics.dll -define:Smartphone;dotNETCF10;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -unsafe+ -optimize+ -debug- %CF_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\CF1.0\Hprose.Client.dll -define:Smartphone;dotNETCF10;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v2.0\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v2.0\WindowsCE\System.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v2.0\WindowsCE\System.Windows.Forms.dll"

set NUMERICS_REF= -reference:"bin\CF2.0\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\CF2.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\CF2.0\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\CF2.0\System.Numerics.dll -define:Smartphone;dotNETCF20;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\CF2.0\Hprose.Client.dll -define:Smartphone;dotNETCF20;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\System.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\System.Windows.Forms.dll"

set NUMERICS_REF= -reference:"bin\CF3.5\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\CF3.5\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\CF3.5\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\CF3.5\System.Numerics.dll -define:Smartphone;dotNETCF35;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\CF3.5\Hprose.Client.dll -define:Smartphone;dotNETCF35;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set NUMERICS_REF= -reference:"bin\Mono\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\Mono\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\Mono\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\Mono\AssemblyInfo.cs
call mcs -out:bin\Mono\System.Numerics.dll -define:dotNET11;MONO -noconfig -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
call mcs -out:bin\Mono\Hprose.dll -define:dotNET11;MONO -noconfig -nowarn:0219 -target:library -optimize+ -debug- -reference:System,System.Web,System.Windows.Forms %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
call mcs -out:bin\Mono\Hprose.Client.dll -define:dotNET11;MONO;ClientOnly -noconfig -nowarn:0219 -target:library -optimize+ -debug- -reference:System,System.Windows.Forms %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set NUMERICS_REF= -reference:"bin\Mono2\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\Mono2\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\Mono2\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\Mono2\AssemblyInfo.cs
call gmcs -out:bin\Mono2\System.Numerics.dll -define:dotNET2;MONO -noconfig -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
call gmcs -out:bin\Mono2\Hprose.dll -define:dotNET2;MONO -noconfig -target:library -optimize+ -debug- -reference:System,System.Web %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
call gmcs -out:bin\Mono2\Hprose.Client.dll -define:dotNET2;MONO;ClientOnly -noconfig -target:library -optimize+ -debug- -reference:System %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

set DHPARAMS_RESOURCE=
set NUMERICS_SRC=
set HPROSE_SRC=
set SL_REFERENCE=
set SL2_PATH=
set SL3_PATH=
set SL4_PATH=
set SL5_PATH=
set WP_REFERENCE=
set WP70_PATH=
set WP71_PATH=
set CF_REFERENCE=
set CF_PATH=
set NUMERICS_REF=
set NUMERICS_INFO=
set HPROSE_INFO=
set HPROSECLIENT_INFO=