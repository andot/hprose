@echo off

if not exist bin mkdir bin
if not exist bin\1.0 mkdir bin\1.0
if not exist bin\1.1 mkdir bin\1.1
if not exist bin\2.0 mkdir bin\2.0
if not exist bin\3.5 mkdir bin\3.5
if not exist bin\3.5\ClientProfile mkdir bin\3.5\ClientProfile
if not exist bin\4.0 mkdir bin\4.0
if not exist bin\4.0\ClientProfile mkdir bin\4.0\ClientProfile
if not exist bin\4.5 mkdir bin\4.5
if not exist bin\4.5\Core mkdir bin\4.5\Core
if not exist bin\WindowsPhone mkdir bin\WindowsPhone
if not exist bin\WindowsPhone71 mkdir bin\WindowsPhone71
if not exist bin\WindowsPhone8 mkdir bin\WindowsPhone8
if not exist bin\SilverLight2 mkdir bin\SilverLight2
if not exist bin\SilverLight3 mkdir bin\SilverLight3
if not exist bin\SilverLight4 mkdir bin\SilverLight4
if not exist bin\SilverLight5 mkdir bin\SilverLight5
if not exist bin\CF1.0 mkdir bin\CF1.0
if not exist bin\CF2.0 mkdir bin\CF2.0
if not exist bin\CF3.5 mkdir bin\CF3.5
if not exist bin\Mono mkdir bin\Mono
if not exist bin\Mono2 mkdir bin\Mono2
if not exist bin\Mono4 mkdir bin\Mono4
if not exist bin\Mono4.5 mkdir bin\Mono4.5

set SL2_PATH=C:\Program Files\Microsoft SDKs\Silverlight\v2.0\Reference Assemblies
set SL3_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v3.0
set SL4_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0
set SL5_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v5.0
set WP70_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0\Profile\WindowsPhone
set WP71_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0\Profile\WindowsPhone71
set WP80_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\WindowsPhone\v8.0
set CF_PATH=C:\Program Files\Microsoft.NET\SDK\CompactFramework
if DEFINED ProgramFiles(x86) set SL2_PATH=C:\Program Files (x86)\Microsoft SDKs\Silverlight\v2.0\Reference Assemblies
if DEFINED ProgramFiles(x86) set SL3_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v3.0
if DEFINED ProgramFiles(x86) set SL4_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0
if DEFINED ProgramFiles(x86) set SL5_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v5.0
if DEFINED ProgramFiles(x86) set WP70_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0\Profile\WindowsPhone
if DEFINED ProgramFiles(x86) set WP71_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\Silverlight\v4.0\Profile\WindowsPhone71
if DEFINED ProgramFiles(x86) set WP80_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\WindowsPhone\v8.0
if DEFINED ProgramFiles(x86) set CF_PATH=C:\Program Files (x86)\Microsoft.NET\SDK\CompactFramework

set NUMERICS_SRC=

set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\BigInteger.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\BigIntegerBuilder.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\BigNumber.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\NumericsHelpers.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\Complex.cs
set NUMERICS_SRC=%NUMERICS_SRC% src\System\Numerics\DoubleUlong.cs

set HPROSE_SRC=
set HPROSE_SRC=%HPROSE_SRC% src\System\Action.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Func.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\NotImplementedException.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\SerializableAttribute.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\MissingMethodException.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Collections\HashMap.cs
set HPROSE_SRC=%HPROSE_SRC% src\System\Collections\Generic\HashMap.cs
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
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\HproseResultMode.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\IHproseInvoker.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\IHproseFilter.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Common\InvokeHelper.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Reflection\Proxy.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Reflection\IInvocationHandler.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Reflection\CtorAccessor.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Reflection\PropertyAccessor.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\IO\TypeEnum.cs
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
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Client\Extension.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Client\HproseClient.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Client\HproseHttpClient.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseService.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseServiceEvent.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpMethods.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpService.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpListenerMethods.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpListenerService.cs
set HPROSE_SRC=%HPROSE_SRC% src\Hprose\Server\HproseHttpListenerServer.cs

echo start compile hprose for .NET 1.0
set NUMERICS_REF= -reference:"bin\1.0\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\1.0\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\1.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\1.0\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v1.0.3705\Csc.exe -out:bin\1.0\System.Numerics.dll -define:dotNET10 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v1.0.3705\Csc.exe -out:bin\1.0\Hprose.Client.dll -define:dotNET10;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v1.0.3705\Csc.exe -out:bin\1.0\Hprose.dll -define:dotNET10 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%

echo start compile hprose for .NET 1.1
set NUMERICS_REF= -reference:"bin\1.1\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\1.1\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\1.1\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\1.1\AssemblyInfo.cs
c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\1.1\System.Numerics.dll -define:dotNET11 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\1.1\Hprose.Client.dll -define:dotNET11;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\1.1\Hprose.dll -define:dotNET11 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%

echo start compile hprose for .NET 2.0
set NUMERICS_REF= -reference:"bin\2.0\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\2.0\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\2.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\2.0\AssemblyInfo.cs
c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\2.0\System.Numerics.dll -define:dotNET2 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\2.0\Hprose.Client.dll -define:dotNET2;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\2.0\Hprose.dll -define:dotNET2 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%

echo start compile hprose for .NET 3.5
set NUMERICS_REF= -reference:"bin\3.5\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\3.5\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\3.5\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\3.5\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\System.Numerics.dll -define:dotNET35 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\Hprose.Client.dll -define:dotNET35;ClientOnly -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\Hprose.dll -define:dotNET35 -filealign:512 -target:library -optimize+ -debug- %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%

echo start compile hprose for .NET 3.5 ClientProfile
set DOTNET_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v3.5\Profile\Client
if DEFINED ProgramFiles(x86) set DOTNET_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v3.5\Profile\Client
set DOTNET_REFERENCE=
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\mscorlib.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Core.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"bin\3.5\ClientProfile\System.Numerics.dll"
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\ClientProfile\System.Numerics.dll -define:dotNET35;ClientProfile -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\ClientProfile\Hprose.Client.dll -define:dotNET35;ClientProfile;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\3.5\ClientProfile\Hprose.dll -define:dotNET35;ClientProfile -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%

echo start compile hprose for .NET 4.0
set HPROSE_INFO= src\AssemblyInfo\Hprose\4.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\4.0\AssemblyInfo.cs
set DOTNET_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0
if DEFINED ProgramFiles(x86) set DOTNET_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0
set DOTNET_REFERENCE=
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\mscorlib.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Core.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"%DOTNET_PATH%\System.Numerics.dll"
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.0\Hprose.Client.dll -define:dotNET4;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Web.dll"
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.0\Hprose.dll -define:dotNET4; -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%

echo start compile hprose for .NET 4.0 ClientProfile
set DOTNET_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0\Profile\Client
if DEFINED ProgramFiles(x86) set DOTNET_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0\Profile\Client
set DOTNET_REFERENCE=
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\mscorlib.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Core.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"%DOTNET_PATH%\System.Numerics.dll"
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.0\ClientProfile\Hprose.Client.dll -define:dotNET4;ClientProfile;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.0\ClientProfile\Hprose.dll -define:dotNET4;ClientProfile -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%

echo start compile hprose for .NET 4.5
set HPROSE_INFO= src\AssemblyInfo\Hprose\4.5\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\4.5\AssemblyInfo.cs
set DOTNET_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5
if DEFINED ProgramFiles(x86) set DOTNET_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5
set DOTNET_REFERENCE=
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\mscorlib.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Core.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"%DOTNET_PATH%\System.Numerics.dll"
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.5\Hprose.Client.dll -define:dotNET4;dotNET45;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Web.dll"
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.5\Hprose.dll -define:dotNET4;dotNET45 -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%

echo start compile hprose for .NET 4.5 Windows Store App
set DOTNET_PATH=C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETCore\v4.5
if DEFINED ProgramFiles(x86) set DOTNET_PATH=C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETCore\v4.5
set DOTNET_REFERENCE=
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Collections.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.IO.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Linq.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Net.Requests.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Net.Primitives.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Reflection.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Reflection.Extensions.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Reflection.Primitives.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Runtime.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Runtime.Extensions.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Runtime.Serialization.Primitives.dll"
set DOTNET_REFERENCE=%DOTNET_REFERENCE% -reference:"%DOTNET_PATH%\System.Threading.dll"
set NUMERICS_REF= -reference:"%DOTNET_PATH%\System.Runtime.Numerics.dll"
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\4.5\Core\Hprose.Client.dll -define:dotNET4;dotNET45;Core;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %DOTNET_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for Silverlight 2.0
set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\System.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\System.Net.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\System.Windows.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL2_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"bin\SilverLight2\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\SilverLight2\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\SilverLight2\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\SilverLight2\System.Numerics.dll -define:SILVERLIGHT;SL2;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\SilverLight2\Hprose.Client.dll -define:SILVERLIGHT;SL2;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for Silverlight 3.0
set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\System.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\System.Net.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\System.Windows.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL3_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"bin\SilverLight3\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\SilverLight3\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\SilverLight3\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\SilverLight3\System.Numerics.dll -define:SILVERLIGHT;SL3;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\SilverLight3\Hprose.Client.dll -define:SILVERLIGHT;SL3;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for Silverlight 4.0
set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\System.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\System.Net.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\System.Windows.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL4_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"bin\SilverLight4\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\SilverLight4\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\SilverLight4\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\SilverLight4\System.Numerics.dll -define:SILVERLIGHT;SL4;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\SilverLight4\Hprose.Client.dll -define:SILVERLIGHT;SL4;ClientOnly -filealign:512 -target:library -noconfig -nowarn:1685 -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for Silverlight 5.0
set SL_REFERENCE=
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\mscorlib.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\System.Core.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\System.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\System.Net.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\System.Windows.dll"
set SL_REFERENCE=%SL_REFERENCE% -reference:"%SL5_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"bin\SilverLight5\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\SilverLight5\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\SilverLight5\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\SilverLight5\System.Numerics.dll -define:SILVERLIGHT;SL5;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\SilverLight5\Hprose.Client.dll -define:SILVERLIGHT;SL5;ClientOnly -filealign:512 -target:library -noconfig -nowarn:1685 -nostdlib+ -optimize+ -debug- %SL_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for Windows Phone 7.0
set WP_REFERENCE=
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\mscorlib.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\System.Core.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\System.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\System.Net.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\System.Windows.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP70_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"bin\WindowsPhone\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\WindowsPhone\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\WindowsPhone\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\WindowsPhone\System.Numerics.dll -define:WINDOWS_PHONE;WP70;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\WindowsPhone\Hprose.Client.dll -define:WINDOWS_PHONE;WP70;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for Windows Phone 7.1
set WP_REFERENCE=
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\mscorlib.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\System.Core.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\System.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\System.Net.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\System.Windows.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP71_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"bin\WindowsPhone71\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\WindowsPhone71\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\WindowsPhone71\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\WindowsPhone71\System.Numerics.dll -define:WINDOWS_PHONE;WP71;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\WindowsPhone71\Hprose.Client.dll -define:WINDOWS_PHONE;WP71;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for Windows Phone 8.0
set WP_REFERENCE=
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP80_PATH%\mscorlib.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP80_PATH%\System.Core.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP80_PATH%\System.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP80_PATH%\System.Net.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP80_PATH%\System.Windows.dll"
set WP_REFERENCE=%WP_REFERENCE% -reference:"%WP80_PATH%\System.Runtime.Serialization.dll"
set NUMERICS_REF= -reference:"bin\WindowsPhone8\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\WindowsPhone8\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\WindowsPhone8\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\WindowsPhone8\System.Numerics.dll -define:WINDOWS_PHONE;WP80;ClientOnly -filealign:512 -target:library -noconfig -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Csc.exe -out:bin\WindowsPhone8\Hprose.Client.dll -define:WINDOWS_PHONE;WP80;ClientOnly -filealign:512 -target:library -noconfig -nowarn:0444 -nostdlib+ -optimize+ -debug- %WP_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for .NET Compact Framework 1.0
set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v1.0\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v1.0\WindowsCE\System.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v1.0\WindowsCE\System.Windows.Forms.dll"
set NUMERICS_REF= -reference:"bin\CF1.0\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\CF1.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\CF1.0\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\CF1.0\System.Numerics.dll -define:Smartphone;dotNETCF10;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -unsafe+ -optimize+ -debug- %CF_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
c:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\Csc.exe -out:bin\CF1.0\Hprose.Client.dll -define:Smartphone;dotNETCF10;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for .NET Compact Framework 2.0
set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v2.0\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v2.0\WindowsCE\System.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v2.0\WindowsCE\System.Windows.Forms.dll"
set NUMERICS_REF= -reference:"bin\CF2.0\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\CF2.0\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\CF2.0\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\CF2.0\System.Numerics.dll -define:Smartphone;dotNETCF20;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Csc.exe -out:bin\CF2.0\Hprose.Client.dll -define:Smartphone;dotNETCF20;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for .NET Compact Framework 3.5
set CF_REFERENCE=
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\mscorlib.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\System.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\System.Core.dll"
set CF_REFERENCE=%CF_REFERENCE% -reference:"%CF_PATH%\v3.5\WindowsCE\System.Windows.Forms.dll"
set NUMERICS_REF= -reference:"bin\CF3.5\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\CF3.5\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\CF3.5\AssemblyInfo.cs
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\CF3.5\System.Numerics.dll -define:Smartphone;dotNETCF35;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_SRC% %NUMERICS_INFO%
C:\WINDOWS\Microsoft.NET\Framework\v3.5\Csc.exe -out:bin\CF3.5\Hprose.Client.dll -define:Smartphone;dotNETCF35;ClientOnly -noconfig -nostdlib -filealign:512 -target:library -optimize+ -debug- %CF_REFERENCE% %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for mono 1.0
set NUMERICS_REF= -reference:"bin\Mono\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\Mono\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\Mono\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\Mono\AssemblyInfo.cs
call mcs -out:bin\Mono\System.Numerics.dll -define:dotNET11;MONO -noconfig -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
call mcs -out:bin\Mono\Hprose.dll -define:dotNET11;MONO -noconfig -nowarn:0219 -target:library -optimize+ -debug- -reference:System,System.Web,System.Windows.Forms %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
call mcs -out:bin\Mono\Hprose.Client.dll -define:dotNET11;MONO;ClientOnly -noconfig -nowarn:0219 -target:library -optimize+ -debug- -reference:System,System.Windows.Forms %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for mono 2.0
set NUMERICS_REF= -reference:"bin\Mono2\System.Numerics.dll"
set NUMERICS_INFO= src\AssemblyInfo\System.Numerics\Mono2\AssemblyInfo.cs
set HPROSE_INFO= src\AssemblyInfo\Hprose\Mono2\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\Mono2\AssemblyInfo.cs
call gmcs -out:bin\Mono2\System.Numerics.dll -sdk:2 -define:dotNET2;MONO -noconfig -target:library -optimize+ -debug- %NUMERICS_SRC% %NUMERICS_INFO%
call gmcs -out:bin\Mono2\Hprose.dll -sdk:2 -define:dotNET2;MONO -noconfig -target:library -optimize+ -debug- -reference:System,System.Web %NUMERICS_REF% %HPROSE_SRC% %HPROSE_INFO%
call gmcs -out:bin\Mono2\Hprose.Client.dll -sdk:2 -define:dotNET2;MONO;ClientOnly -noconfig -target:library -optimize+ -debug- -reference:System %NUMERICS_REF% %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for mono 4.0
set HPROSE_INFO= src\AssemblyInfo\Hprose\Mono4\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\Mono4\AssemblyInfo.cs
call gmcs -out:bin\Mono4\Hprose.dll -sdk:4 -define:dotNET4;MONO -noconfig -target:library -optimize+ -debug- -reference:System,System.Core,System.Runtime.Serialization,System.Web,System.Numerics %HPROSE_SRC% %HPROSE_INFO%
call gmcs -out:bin\Mono4\Hprose.Client.dll -sdk:4 -define:dotNET4;MONO;ClientOnly -noconfig -target:library -optimize+ -debug- -reference:System,System.Core,System.Runtime.Serialization,System.Numerics %HPROSE_SRC% %HPROSECLIENT_INFO%

echo start compile hprose for mono 4.5
set HPROSE_INFO= src\AssemblyInfo\Hprose\Mono4.5\AssemblyInfo.cs
set HPROSECLIENT_INFO= src\AssemblyInfo\Hprose.Client\Mono4.5\AssemblyInfo.cs
call gmcs -out:bin\Mono4.5\Hprose.dll -sdk:4.5 -define:dotNET4;dotNET45;MONO -noconfig -target:library -optimize+ -debug- -reference:System,System.Core,System.Runtime.Serialization,System.Web,System.Numerics %HPROSE_SRC% %HPROSE_INFO%
call gmcs -out:bin\Mono4.5\Hprose.Client.dll -sdk:4.5 -define:dotNET4;dotNET45;MONO;ClientOnly -noconfig -target:library -optimize+ -debug- -reference:System,System.Core,System.Runtime.Serialization,System.Numerics %HPROSE_SRC% %HPROSECLIENT_INFO%

set DHPARAMS_RESOURCE=
set NUMERICS_SRC=
set HPROSE_SRC=
set DOTNET_PATH=
set DOTNET_REFERENCE=
set SL_REFERENCE=
set SL2_PATH=
set SL3_PATH=
set SL4_PATH=
set SL5_PATH=
set WP_REFERENCE=
set WP70_PATH=
set WP71_PATH=
set WP80_PATH=
set CF_REFERENCE=
set CF_PATH=
set NUMERICS_REF=
set NUMERICS_INFO=
set HPROSE_INFO=
set HPROSECLIENT_INFO=