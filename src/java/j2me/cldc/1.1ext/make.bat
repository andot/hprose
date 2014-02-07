@echo off
set JavaME_PATH=C:\Program Files\NetBeans 7.3 Beta 2\mobility\Java_ME_platform_SDK_3.2
if not exist build mkdir build
if not exist dist mkdir dist
javac -g:none -source 1.2 -target 1.2 -bootclasspath "%JavaME_PATH%\lib\cldc_1.1.jar";"%JavaME_PATH%\lib\midp_2.0.jar"  -d build src\java\lang\*.java src\java\math\*.java src\java\util\*.java src\hprose\common\*.java src\hprose\io\*.java src\hprose\client\*.java
"%JavaME_PATH%\bin\preverify.exe" -classpath "%JavaME_PATH%\lib\cldc_1.1.jar";"%JavaME_PATH%\lib\midp_2.0.jar" -d build build
jar cfm dist\hprose_for_cldc_1.1_ext.jar manifest -C build .
rd /S /Q build

for %%I in (dist\hprose_for_cldc_1.1_ext.jar) do echo MIDlet-Jar-Size: %%~zI>dist\hprose_for_cldc_1.1_ext.jad
echo MIDlet-Jar-URL: hprose_for_cldc_1.1_ext.jar>>dist\hprose_for_cldc_1.1_ext.jad
echo MIDlet-Name: hprose for cldc 1.1 ext>>dist\hprose_for_cldc_1.1_ext.jad
echo MIDlet-Vendor: Vendor>>dist\hprose_for_cldc_1.1_ext.jad
echo MIDlet-Version: 1.0>>dist\hprose_for_cldc_1.1_ext.jad
echo MicroEdition-Configuration: CLDC-1.1>>dist\hprose_for_cldc_1.1_ext.jad
echo MicroEdition-Profile: MIDP-2.0>>dist\hprose_for_cldc_1.1_ext.jad
