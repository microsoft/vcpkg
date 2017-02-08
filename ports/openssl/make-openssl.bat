set build=%1

perl Configure no-asm no-hw no-dso VC-WINUNIVERSAL

call ms\do_winuniversal.bat

call ms\setVSvars.bat universal10.0%build%

nmake -f ms\ntdll.mak

