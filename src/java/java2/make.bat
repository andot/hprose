@echo off
if not exist build mkdir build
if not exist dist mkdir dist
javac -classpath lib\servlet.jar -d build src\hprose\common\*.java src\hprose\client\*.java src\hprose\io\*.java src\hprose\server\*.java
jar cf dist/hprose_for_java_1.4.jar -C build .
del /Q build\hprose\server\*
rmdir build\hprose\server
del /Q build\hprose\common\HproseMethod.class
del /Q build\hprose\common\HproseMethods.class
jar cf dist/hprose_client_for_java_1.4.jar -C build .
