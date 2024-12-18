# ROS-DDS-MessageGen

用于生成不同的DDS消息文件（包括ROS2消息转换）

文件结构说明：

- IdlMessages：原始的idl消息文件

- CppMessages：idl消息文件自动生成的cpp代码
- PythonMessages：idl消息文件自动生成的python库代码
- Tools：用于自动生成的工具
- `GenerateCppMessage.bat`：Idl文件转换为cpp代码的批处理程序
- `GeneratePythonMessage.bat`：Idl文件转换为python代码的批处理程序

## 依赖说明

Python 依赖包安装：

```
pip install -U colcon-common-extensions vcstool
```

JAVA运行时：

[点此下载JDK](https://www.oracle.com/java/technologies/downloads/?er=221886#java17)，支持11-19版本的JDK。

## 使用说明

### C++ 消息

直接双击`GenerateCppMessage.bat`即可，将生成的消息`.hpp`和`.cpp`文件（在`CppMessages`内）导入自己的工程即可。

***注意：与fast-dds-gen生成不同的是，这里将.cxx后缀改成了.cpp后缀！***

### Python 消息

使用`Developer PowerShell for VS 20XX`打开，出现一个终端，使用`cd`命令

```bash
cd [仓库目录]
```

然后输入

```bash
.\GeneragePythonMessage.bat
```

等待生成。

将所有生成的消息python库文件及依赖（在`PythonMessages\binary`下）复制到自己的代码下即可。



### ROS2消息

把ROS2消息包文件放入ROSMessages文件夹，按一下文件夹放置文件：

```bash
├── ROSMessages # 三方库存放位置
    ├── [ROS2 pkg name] # ROS2 包名
    	├── msg # ROS2 消息文件
    	└── srv # ROS2 服务文件
```

运行：双击`GenerateROSCppMessage.bat`即可。

生成文件：

- `.idl`文件在仓库根目录的`ROSIdlMessages`文件夹
- `.cpp,.hpp`文件在仓库根目录的`ROSCppMessages`文件夹

***注意：与fast-dds-gen生成不同的是，这里将.cxx后缀改成了.cpp后缀！***
