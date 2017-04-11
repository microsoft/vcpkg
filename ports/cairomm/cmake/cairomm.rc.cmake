
#define APSTUDIO_READONLY_SYMBOLS

#include <windows.h>

#undef APSTUDIO_READONLY_SYMBOLS

#if !defined(AFX_RESOURCE_DLL) || defined(AFX_TARG_ENU)
#ifdef _WIN32
LANGUAGE LANG_ENGLISH, SUBLANG_ENGLISH_US
#pragma code_page(1252)
#endif //_WIN32

#ifdef APSTUDIO_INVOKED

1 TEXTINCLUDE
BEGIN
    "resource.h\0"
END

2 TEXTINCLUDE
BEGIN
    "#include ""afxres.h""\r\n"
    "\0"
END

3 TEXTINCLUDE
BEGIN
    "\r\n"
    "\0"
END

#endif    // APSTUDIO_INVOKED

VS_VERSION_INFO VERSIONINFO
 FILEVERSION @CAIROMM_MAJOR_VERSION@,@CAIROMM_MINOR_VERSION@,@CAIROMM_MICRO_VERSION@,1
 PRODUCTVERSION @CAIROMM_MAJOR_VERSION@,@CAIROMM_MINOR_VERSION@,@CAIROMM_MICRO_VERSION@,1
 FILEFLAGSMASK 0x17L
#ifdef _DEBUG
 FILEFLAGS 0x1L
#else
 FILEFLAGS 0x0L
#endif
 FILEOS 0x4L
 FILETYPE 0x2L
 FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904b0"
        BEGIN
            VALUE "CompanyName", "The cairomm development team (see AUTHORS)"
            VALUE "FileDescription", "The official C++ wrapper for cairo"
            VALUE "FileVersion", "@VERSION@"
            VALUE "LegalCopyright", "Distribution is under the LGPL (see COPYING)"
            VALUE "OriginalFilename", "cairomm-1.0"
            VALUE "ProductName", "cairomm"
            VALUE "ProductVersion", "@VERSION@"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 1200
    END
END

#endif    // English (U.S.) resources

#ifndef APSTUDIO_INVOKED

#endif    // not APSTUDIO_INVOKED
