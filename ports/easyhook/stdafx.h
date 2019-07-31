// EasyHook (File: EasyHookDll\stdafx.h)
//
// Copyright (c) 2009 Christoph Husse & Copyright (c) 2015 Justin Stenning
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Please visit https://easyhook.github.io for more information
// about the project and latest updates.

#ifndef _STDAFX_H_
#define _STDAFX_H_


// support for Windows 2000 SP4 and later...
__pragma(warning(push))
__pragma(warning(disable:4005))
#define NTDDI_VERSION           NTDDI_WIN2KSP4
#define _WIN32_WINNT            0x500
#define _WIN32_IE_              _WIN32_IE_WIN2KSP4
__pragma(warning(pop))

#pragma warning (disable:4100) // unreference formal parameter
#pragma warning(disable:4201) // nameless struct/union
#pragma warning(disable:4102) // unreferenced label
#pragma warning(disable:4127) // conditional expression is constant


#include <windows.h>
#include <winnt.h>
#include <winternl.h>
#include <stdio.h>
#include <stdlib.h>
#include <tlhelp32.h>
#include <strsafe.h>
#include <crtdbg.h>

#pragma warning(disable: 4005)
#include <ntstatus.h>
#pragma warning(default: 4005)

#ifdef __cplusplus
extern "C"{
#endif

#include "../Public/EasyHook.h"
#include "../DriverShared/DriverShared.h"

BOOL RtlFileExists(WCHAR* InPath);
LONG RtlGetWorkingDirectory(WCHAR* OutPath, ULONG InMaxLength);
LONG RtlGetCurrentModulePath(WCHAR* OutPath, ULONG InMaxLength);

#define RTL_SUCCESS(ntstatus)       SUCCEEDED(ntstatus)

HOOK_ACL* LhBarrierGetAcl();
void LhBarrierThreadDetach();
NTSTATUS LhBarrierProcessAttach();
void LhBarrierProcessDetach();
ULONGLONG LhBarrierIntro(LOCAL_HOOK_INFO* InHandle, void* InRetAddr, void** InAddrOfRetAddr);
void* __stdcall LhBarrierOutro(LOCAL_HOOK_INFO* InHandle, void** InAddrOfRetAddr);

LONG DbgRelocateRIPRelative(
	        ULONGLONG InOffset,
	        ULONGLONG InTargetOffset,
            BOOL* OutWasRelocated);

EASYHOOK_NT_INTERNAL RhSetWakeUpThreadID(ULONG InThreadID);


extern HMODULE             hNtDll;
extern HMODULE             hKernel32;
extern HMODULE             hCurrentModule;
extern HANDLE              hEasyHookHeap;

// this is just to make machine code management easier
#define WRAP_ULONG64(Decl)\
union\
{\
	ULONG64 UNUSED;\
	Decl;\
}\
    
#define UNUSED2(y) __Unused_##y
#define UNUSED1(y) UNUSED2(y)
#define UNUSED UNUSED1(__COUNTER__)

typedef struct _REMOTE_INFO_
{
	// will be the same for all processes
	WRAP_ULONG64(wchar_t* UserLibrary); // fixed 0
	WRAP_ULONG64(wchar_t* EasyHookPath); // fixed 8
	WRAP_ULONG64(wchar_t* PATH); // fixed 16
	WRAP_ULONG64(char* EasyHookEntry); // fixed 24
	WRAP_ULONG64(void* RemoteEntryPoint); // fixed 32
	WRAP_ULONG64(void* LoadLibraryW); // fixed; 40
	WRAP_ULONG64(void* FreeLibrary); // fixed; 48
	WRAP_ULONG64(void* GetProcAddress); // fixed; 56
	WRAP_ULONG64(void* VirtualFree); // fixed; 64
	WRAP_ULONG64(void* VirtualProtect); // fixed; 72
	WRAP_ULONG64(void* ExitThread); // fixed; 80
	WRAP_ULONG64(void* GetLastError); // fixed; 88
	
    BOOL            IsManaged;
	HANDLE          hRemoteSignal; 
	DWORD           HostProcess;
	DWORD           Size;
	BYTE*           UserData;
	DWORD           UserDataSize;
    ULONG           WakeUpThreadID;
}REMOTE_INFO, *LPREMOTE_INFO;


#ifdef __cplusplus
}
#endif

#endif