@echo off
cd %~dp0

:: 清理旧文件
powershell -Command "Remove-Item -Path %dir%ROSIdlMessages -Recurse -Force"
powershell -Command "Remove-Item -Path %dir%ROSCppMessages -Recurse -Force"

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

python.exe -u %dir%Tools/ROSmsg2idl.py

pause
