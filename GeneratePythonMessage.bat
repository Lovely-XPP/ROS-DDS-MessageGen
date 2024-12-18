@echo off
cd %~dp0

:: 清理旧文件
powershell -Command "Remove-Item -Path %dir%PythonMessages/src -Recurse -Force"
powershell -Command "Remove-Item -Path %dir%PythonMessages/build -Recurse -Force"
powershell -Command "Remove-Item -Path %dir%PythonMessages/install -Recurse -Force"
powershell -Command "Remove-Item -Path %dir%PythonMessages/binary -Recurse -Force"
powershell -Command "Remove-Item -Path %dir%PythonMessages/log -Recurse -Force"
:: 创建文件夹
mkdir "%dir%PythonMessages/src"


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

%java_exec% -jar "%dir%/Tools/fastddsgen.jar" -d %dir%/PythonMessages/src %dir%/IdlMessages/*.idl -python -fusion -no-dependencies -replace

echo ################################# 消息转换完成.
echo ------------------------------------------------
echo ################################# 编译消息对应的python库文件...

cd PythonMessages
:: replace '\' with '/' -> src/CMakeLists.txt
set "source=src/CMakeLists.txt"
set "dest=src/CMakeLists.txt"
set "search=\\"
set "replace=/"
powershell -Command "(Get-Content '%source%') -replace '%search%', '%replace%' | Set-Content '%dest%'"
:: fix module files with relative path -> src/CMakeLists.txt
set "source=src/CMakeLists.txt"
set "dest=src/CMakeLists.txt"
set "search=\ \$\{PROJECT_NAME\}.i"
set "replace= IdlMessages/${PROJECT_NAME}.i"
powershell -Command "(Get-Content '%source%') -replace '%search%', '%replace%' | Set-Content '%dest%'"
:: add include folder -> src/CMakeLists.txt
set "source=src/CMakeLists.txt"
set "dest=src/CMakeLists.txt"
set "search=include_directories\(\$\{PYTHON_INCLUDE_PATH\}\)"
set "replace=include_directories(${PYTHON_INCLUDE_PATH} IdlMessages)"
powershell -Command "(Get-Content '%source%') -replace '%search%', '%replace%' | Set-Content '%dest%'"
:: add OpenSSL library -> src/CMakeLists.txt
set "source=src/CMakeLists.txt"
set "dest=src/CMakeLists.txt"
set "search=\ \ \ \ fastdds"
set "replace=    fastdds ${OPENSSL_LIBRARIES} "
powershell -Command "(Get-Content '%source%') -replace '%search%', '%replace%' | Set-Content '%dest%'"
:: changed Shared with STATIC -> src/CMakeLists.txt
set "source=src/CMakeLists.txt"
set "dest=src/CMakeLists.txt"
set "search=\$\{PROJECT_NAME\}\ SHARED"
set "replace=${PROJECT_NAME} STATIC"
powershell -Command "(Get-Content '%source%') -replace '%search%', '%replace%' | Set-Content '%dest%'"
:: Not Rename with __init__.py -> src/CMakeLists.txt
set "source=src/CMakeLists.txt"
set "dest=src/CMakeLists.txt"
set "search=\ RENAME\ __init__.py"
set "replace="
powershell -Command "(Get-Content '%source%') -replace '%search%', '%replace%' | Set-Content '%dest%'"
colcon build
cd ..

echo ################################# 编译完成.
echo ------------------------------------------------
echo ################################# 导出库文件...
:: 复制 DLL
:: 设置要遍历的根目录
set "rootDir=%dir%PythonMessages\build\python_messages\src"
set "dest=%dir%PythonMessages\binary"

:: 遍历根目录下的所有子文件夹并统一复制到binary文件夹
for %%i in ("%rootDir%\*.py") do (
    set "filename=%%~ni"
    set "pythonsrc=%dir%PythonMessages\build\python_messages\src\!filename!.py"
    set "src=%dir%PythonMessages\install\python_messages\lib\site-packages\!filename!"
    echo F | xcopy !pythonsrc! "!src!\__init__.py" /Q /R /Y /D 
    powershell -Command "(Get-Content '!src!\__init__.py') -replace 'if\ __import__', '# if  __import__' | Set-Content '!src!\__init__.py'"
    echo D | xcopy %%i %dest% /Q /R /Y /D 
    echo D | xcopy "!src!\_!filename!Wrapper.pyd" %dest% /Q /R /Y /D 
    echo F | xcopy "!src!\__init__.py" "%dest%\!filename!.py" /Q /R /Y /D 
)

:: 复制openssl dll

pause