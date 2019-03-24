@echo off

::
::  VC-LTL自动化加载配置，建议你将此文件单独复制到你的工程再使用，该文件能自动识别当前环境是否存在VC-LTL，并且自动应用。
::
::  使用方法：
::    1. 启动 vcvars32.bat/vcvars64.bat 然后执行此脚本，运行完成后将自动修改include以及lib环境变量，方便nmake以及纯cl用户引用VC-LTL。
::    2. 务必保证所有依赖的静态库也均用VC-LTL重新编译。
::
::  VC-LTL默认搜索顺序
::	  1. “VC-LTL helper for nmake.cmd”所在根目录，即 %~dp0
::	  2. “VC-LTL helper for nmake.cmd”所在根目录下的VC-LTL目录，即 %~dp0VC-LTL
::	  3. “VC-LTL helper for nmake.cmd”所在父目录，即 %~dp0..
::	  3. “VC-LTL helper for nmake.cmd”所在父目录下的VC-LTL目录，即 %~dp0..\VC-LTL
::    4. 当前目录，即 %cd%
::    5. 当前目录下的VC-LTL目录，即 %cd%\VC-LTL
::    6. 当前目录的父目录下的VC-LTL目录，即 %cd%\..\VC-LTL
::    7. 注册表HKEY_CURRENT_USER\Code\VC-LTL@Root
::
::  把VC-LTL放在其中一个位置即可，VC-LTL就能被自动引用。
::
::  如果你对默认搜索顺序不满，你可以修改此文件。你也可以直接指定%VC_LTL_Root%环境变量更加任性的去加载VC-LTL。
::




:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::VC-LTL设置::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::取消下方注释可以开启XP兼容模式，默认才用Vista兼容模式。
::set SupportWinXP=true

::取消下方注释可以开启VC-LTL轻量模式，轻量模式更加注重体积控制，但是CRT规范将会维持在VS2008。如果你需要高度兼容微软UCRT，那么请不要打开此选项！！！
::set DisableAdvancedSupport=true

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::





if "%VC_LTL_Root%" NEQ "" goto LoadConfig

::搜索VC-LTL目录

::脚本文件根目录存在VC-LTL？
if exist "%~dp0_msvcrt.h" set VC_LTL_Root=%~dp0&& goto LoadConfig

::脚本文件根目录下存在VC-LTL？
if exist "%~dp0VC-LTL\_msvcrt.h" set VC_LTL_Root=%~dp0VC-LTL&& goto LoadConfig

::脚本文件父目录存在VC-LTL？
if exist "%~dp0..\_msvcrt.h" set VC_LTL_Root=%~dp0..&& goto LoadConfig

::脚本文件父目录存在VC-LTL？
if exist "%~dp0..\VC-LTL\_msvcrt.h" set VC_LTL_Root=%~dp0..\VC-LTL&& goto LoadConfig

::当前根目录就是VC-LTL？
if exist "%cd%\_msvcrt.h" set VC_LTL_Root=%cd%&& goto LoadConfig

::当前根目录存在VC-LTL？
if exist "%cd%\VC-LTL\_msvcrt.h" set VC_LTL_Root=%cd%\VC-LTL&& goto LoadConfig

::当前父目录存在VC-LTL？
if exist "%cd%\..\VC-LTL\_msvcrt.h" set VC_LTL_Root=%cd%\..\VC-LTL&& goto LoadConfig


::读取注册表 HKCU\Code\VC-LTL@Root
for /f "tokens=1,2*" %%i in ('reg query "HKCU\Code\VC-LTL" /v Root ') do set VC_LTL_Root=%%k

if "%VC_LTL_Root%" == "" goto:eof


:LoadConfig

call "%VC_LTL_Root%\config\config.cmd"
