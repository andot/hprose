@echo off
if not exist build mkdir build
if not exist dist mkdir dist
javac -source 1.4 -target 1.4 -Xlint:unchecked -bootclasspath "C:\Program Files (x86)\Java\j2re1.4.2\lib\rt.jar" -classpath lib\servlet.jar -d build src\hprose\common\*.java src\hprose\client\*.java src\hprose\io\*.java src\hprose\server\*.java
jar cf dist/hprose_for_java_1.4.jar -C build .
del /Q build\hprose\server\*
rmdir build\hprose\server
del /Q build\hprose\common\HproseMethod.class
del /Q build\hprose\common\HproseMethods.class
jar cf dist/hprose_client_for_java_1.4.jar -C build .
