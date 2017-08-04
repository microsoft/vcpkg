set build=%1

perl Configure no-asm no-hw no-dso VC-WINUNIVERSAL -FS -FIWindows.h

set LibPath=%LibPath%;%WindowsSdkDir%References\%WindowsSDKLibVersion%Windows.Foundation.FoundationContract\3.0.0.0\
set LibPath=%LibPath%;%WindowsSdkDir%References\%WindowsSDKLibVersion%Windows.Foundation.FoundationContract\2.0.0.0\
set LibPath=%LibPath%;%WindowsSdkDir%References\%WindowsSDKLibVersion%Windows.Foundation.FoundationContract\1.0.0.0\
set LibPath=%LibPath%;%WindowsSdkDir%References\%WindowsSDKLibVersion%Windows.Foundation.UniversalApiContract\4.0.0.0\
set LibPath=%LibPath%;%WindowsSdkDir%References\%WindowsSDKLibVersion%Windows.Foundation.UniversalApiContract\3.0.0.0\
set LibPath=%LibPath%;%WindowsSdkDir%References\%WindowsSDKLibVersion%Windows.Foundation.UniversalApiContract\2.0.0.0\
set LibPath=%LibPath%;%WindowsSdkDir%References\%WindowsSDKLibVersion%Windows.Foundation.UniversalApiContract\1.0.0.0\

call ms\do_winuniversal.bat

mkdir inc32\openssl

jom -j %NUMBER_OF_PROCESSORS% -k -f ms\ntdll.mak
REM due to a race condition in the build, we need to have a second single-threaded pass.
nmake -f ms\ntdll.mak

