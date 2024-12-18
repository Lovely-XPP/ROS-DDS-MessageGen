@echo off
cd %~dp0

:: ������ļ�
powershell -Command "Remove-Item -Path %dir%CppMessages -Recurse -Force"
:: �����ļ���
mkdir CppMessages

echo ################################# ��idl��Ϣת��Ϊc++�ļ�...

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

echo ################################# ��Ϣת�����.

echo ------------------------------------------------
echo ################################# �������ļ�...

:: .cxx -> .cpp
python.exe -u %dir%Tools/handle_cppmessages.py

echo ################################# �������ļ����.
echo ------------------------------------------------
pause