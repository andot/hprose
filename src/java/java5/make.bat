@echo off
if not exist build mkdir build
if not exist dist mkdir dist
javac -source 5 -target 5 -Xlint:unchecked -bootclasspath "C:\Program Files\Java\jdk1.5.0_22\jre\lib\rt.jar" -cp lib\servlet.jar -d build src\hprose\common\*.java src\hprose\client\*.java src\hprose\io\*.java src\hprose\server\*.java
jar cf dist/hprose_for_java_5.jar -C build .
del /Q build\hprose\server\*
rmdir build\hprose\server
del /Q build\hprose\common\HproseMethod.class
del /Q build\hprose\common\HproseMethods.class
jar cf dist/hprose_client_for_java_5.jar -C build .

javac -source 6 -target 6 -Xlint:unchecked -bootclasspath "C:\Program Files\Java\jdk1.6.0_35\jre\lib\rt.jar" -cp lib\servlet.jar -d build src\hprose\common\*.java src\hprose\client\*.java src\hprose\io\*.java src\hprose\server\*.java
jar cf dist/hprose_for_java_6.jar -C build .
del /Q build\hprose\server\*
rmdir build\hprose\server
del /Q build\hprose\common\HproseMethod.class
del /Q build\hprose\common\HproseMethods.class
jar cf dist/hprose_client_for_java_6.jar -C build .

javac -source 7 -target 7 -Xlint:unchecked -cp lib\servlet.jar -d build src\hprose\common\*.java src\hprose\client\*.java src\hprose\io\*.java src\hprose\server\*.java
jar cf dist/hprose_for_java_7.jar -C build .
del /Q build\hprose\server\*
rmdir build\hprose\server
del /Q build\hprose\common\HproseMethod.class
del /Q build\hprose\common\HproseMethods.class
jar cf dist/hprose_client_for_java_7.jar -C build .
