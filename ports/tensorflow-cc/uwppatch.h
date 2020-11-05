#pragma once

#include<Windows.h>

#if defined(WINAPI_FAMILY) && WINAPI_FAMILY == WINAPI_FAMILY_APP

#define STARTF_USESTDHANDLES 0x00000100
#define HANDLE_FLAG_INHERIT 0x00000001


#define LOAD_WITH_ALTERED_SEARCH_PATH 0x00000008


#define MAX_SYM_NAME 512


#define INVALID_HANDLE_VALUE ((HANDLE)-1)
#define MAX_PATH 256
#define FILE_ATTRIBUTE_DIRECTORY 16


#ifndef _FILE_DEFINED
    #define _FILE_DEFINED
    typedef struct _iobuf
    {
        void* _Placeholder;
    } FILE;
#endif


typedef struct _SYMBOL_INFO {
  ULONG   SizeOfStruct;
  ULONG   TypeIndex;
  ULONG64 Reserved[2];
  ULONG   Index;
  ULONG   Size;
  ULONG64 ModBase;
  ULONG   Flags;
  ULONG64 Value;
  ULONG64 Address;
  ULONG   Register;
  ULONG   Scope;
  ULONG   Tag;
  ULONG   NameLen;
  ULONG   MaxNameLen;
  CHAR    Name[1];
} SYMBOL_INFO, *PSYMBOL_INFO;


typedef struct _IMAGEHLP_LINE64 {
  DWORD   SizeOfStruct;
  PVOID   Key;
  DWORD   LineNumber;
  PCHAR   FileName;
  DWORD64 Address;
} IMAGEHLP_LINE64, *PIMAGEHLP_LINE64;


typedef struct _IMAGEHLP_LINE {
  DWORD SizeOfStruct;
  PVOID Key;
  DWORD LineNumber;
  PCHAR FileName;
  DWORD Address;
} IMAGEHLP_LINE, *PIMAGEHLP_LINE;


inline BOOL SetHandleInformation(HANDLE hObject, DWORD dwMask, DWORD dwFlags) 
{ 
	return FALSE; 
}

inline LSTATUS RegOpenKeyExA(
  HKEY   hKey,
  LPCSTR lpSubKey,
  DWORD  ulOptions,
  REGSAM samDesired,
  PHKEY  phkResult
)
{
	return 1;
}

inline LSTATUS RegQueryValueExA(
  HKEY    hKey,
  LPCSTR  lpValueName,
  LPDWORD lpReserved,
  LPDWORD lpType,
  LPBYTE  lpData,
  LPDWORD lpcbData
)
{
	return 1;
}

inline LSTATUS RegCloseKey(
  HKEY hKey
)
{
	return 1;
}

inline LSTATUS RegGetValueA(HKEY    hkey,  LPCSTR  lpSubKey,  LPCSTR  lpValue,  DWORD   dwFlags,  LPDWORD pdwType,  PVOID   pvData,  LPDWORD pcbData) 
{ 
	return 1; 
}

inline HMODULE GetModuleHandleA(
  LPCSTR lpModuleName
)
{
	return NULL;
}

inline HMODULE GetModuleHandleW(LPCWSTR lpModuleName) 
{ 
	return NULL; 
}

inline BOOL PathMatchSpecW(LPCWSTR pszFile, LPCWSTR pszSpec) 
{ 
	return FALSE; 
}

inline HANDLE CreateFileW(
	LPCWSTR               lpFileName,
	DWORD                 dwDesiredAccess,
	DWORD                 dwShareMode,
	LPSECURITY_ATTRIBUTES lpSecurityAttributes,
	DWORD                 dwCreationDisposition,
	DWORD                 dwFlagsAndAttributes,
	HANDLE                hTemplateFile
)
{
	return NULL;
}

inline LPVOID MapViewOfFileEx(
	HANDLE hFileMappingObject,
	DWORD  dwDesiredAccess,
	DWORD  dwFileOffsetHigh,
	DWORD  dwFileOffsetLow,
	SIZE_T dwNumberOfBytesToMap,
	LPVOID lpBaseAddress
)
{
	return NULL;
}


inline LSTATUS SHGetValueA(
  HKEY   hkey,
  LPCSTR pszSubKey,
  LPCSTR pszValue,
  DWORD  *pdwType,
  void   *pvData,
  DWORD  *pcbData
)
{
	return 1;
}

inline BOOL GetUserProfileDirectoryW(
  HANDLE  hToken,
  LPWSTR  lpProfileDir,
  LPDWORD lpcchSize
)
{
	return FALSE;
}

inline BOOL MoveFileW(
  LPCWSTR lpExistingFileName,
  LPCWSTR lpNewFileName
)
{
	return FALSE;
}

inline DWORD GetFileVersionInfoSizeA(
  LPCSTR  lptstrFilename,
  LPDWORD lpdwHandle
)
{
	return 0;
}

inline BOOL GetFileVersionInfoA(
  LPCSTR lptstrFilename,
  DWORD  dwHandle,
  DWORD  dwLen,
  LPVOID lpData
)
{
	return FALSE;
}

inline FILE* _popen(
    const char *command,
    const char *mode
)
{
	return NULL;
}

inline int _pclose(
FILE* stream
)
{
	return 0;
}

inline HMODULE LoadLibraryExW(
  LPCWSTR lpLibFileName,
  HANDLE  hFile,
  DWORD   dwFlags
)
{
	return NULL;
}

inline HANDLE CreateFileMappingA(
  HANDLE                hFile,
  LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
  DWORD                 flProtect,
  DWORD                 dwMaximumSizeHigh,
  DWORD                 dwMaximumSizeLow,
  LPCSTR                lpName
)
{
	return NULL;
}

inline BOOL PathIsDirectoryW(
  LPCWSTR pszPath
)
{
	return FALSE;
}

inline char *getcwd(
   char *buffer,
   int maxlen
)
{
	return NULL;
}


inline DWORD SymSetOptions(
  DWORD SymOptions
)
{
	return 0;
}

inline BOOL SymInitialize(
  HANDLE hProcess,
  PCSTR  UserSearchPath,
  BOOL   fInvadeProcess
)
{
	return FALSE;
}

inline BOOL SymFromAddr(
  HANDLE       hProcess,
  DWORD64      Address,
  PDWORD64     Displacement,
  PSYMBOL_INFO Symbol
)
{
	return FALSE;
}



inline BOOL FindClose(
  HANDLE hFindFile
)
{
	return FALSE;
}



inline BOOL FindNextFileW(
  HANDLE             hFindFile,
  LPWIN32_FIND_DATAW lpFindFileData
)
{
	return FALSE;
}


inline DWORD GetLastError()
{
	return 1;
}

inline BOOL CloseHandle(
  HANDLE hObject
)
{
	return FALSE;
}


inline BOOLEAN RtlGenRandom(
  PVOID RandomBuffer,
  ULONG RandomBufferLength
)
{
	return FALSE;
}

#endif


#ifndef _CRT_USE_WINAPI_FAMILY_DESKTOP_APP
inline char* getenv(const char* env_var) { return nullptr; }
#endif
