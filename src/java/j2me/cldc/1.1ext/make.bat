@echo off
set JavaME_PATH=C:\Java_ME_platform_SDK_3.0.5
if not exist build mkdir build
if not exist dist mkdir dist
javac -g:none -source 1.2 -target 1.2 -bootclasspath "%JavaME_PATH%\lib\cldc_1.1.jar";"%JavaME_PATH%\lib\midp_1.0.jar" -d build src\java\lang\*.java src\java\math\*.java src\java\util\*.java src\hprose\common\*.java src\hprose\io\*.java src\hprose\client\*.java
"%JavaME_PATH%\bin\preverify.exe" -classpath "%JavaME_PATH%\lib\cldc_1.1.jar";"%JavaME_PATH%\lib\midp_1.0.jar" -d build build
jar cfm dist\hprose_cldc_1.1.jar manifest -C build .
rd /S /Q build