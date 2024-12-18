@echo off
cd %~dp0

:: 清理旧文件
powershell -Command "Remove-Item -Path %dir%CppMessages -Recurse -Force"
:: 创建文件夹
mkdir CppMessages

echo ################################# 将idl消息转换为c++文件...

setlocal enabledelayedexpansion  

set dir=%~dp0

:: Check java binary.
set java_exec=java

java -version > NUL 2>&1

if not %ERRORLEVEL%==0 (
   if not "%JAVA_HOME%"=="" (
      set java_exec="%JAVA_HOME%\bin\java"
   ) else (
      echo Java binary cannot be found. Please, make sure its location is in the PATH environment variable or set JAVA_HOME environment variable.
      exit /B 65
   )
)

cd %dir%IdlMessages
%java_exec% -jar "%dir%/Tools/fastddsgen.jar" -d %dir%CppMessages *.idl -replace

echo ################################# 消息转换完成.

echo ------------------------------------------------
echo ################################# 导出库文件...

:: .cxx -> .cpp
python.exe -u %dir%Tools/handle_cppmessages.py

echo ################################# 导出库文件完成.
echo ------------------------------------------------
pause