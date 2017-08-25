@echo off

IF "%2"=="" (set WPDPACKDESTDIR=.\WpdPack\) ELSE (set WPDPACKDESTDIR=%2)

IF ""=="%1" (set WINPCAPSOURCEDIR=.\) ELSE (set WINPCAPSOURCEDIR=%1) 

echo Creating \Lib folder
mkdir %WPDPACKDESTDIR% 		>nul 2>nul
mkdir %WPDPACKDESTDIR%\Bin 	>nul 2>nul
mkdir %WPDPACKDESTDIR%\Bin\x64	>nul 2>nul

xcopy /v /Y "%WINPCAPSOURCEDIR%\wpcap\PRJ\Release No AirPcap\x86\wpcap.dll"		%WPDPACKDESTDIR%\Bin\ >nul
xcopy /v /Y "%WINPCAPSOURCEDIR%\wpcap\PRJ\Release No AirPcap\x64\wpcap.dll"		%WPDPACKDESTDIR%\Bin\x64 >nul
xcopy /v /Y %WINPCAPSOURCEDIR%\packetNtx\Dll\Project\Release\x86\packet.dll	 	%WPDPACKDESTDIR%\Bin\ >nul
xcopy /v /Y %WINPCAPSOURCEDIR%\packetNtx\Dll\Project\Release\x64\packet.dll	 	%WPDPACKDESTDIR%\Bin\x64 >nul

echo Folder \Bin created successfully

set WPDPACKDESTDIR=
set WINPCAPSOURCEDIR=