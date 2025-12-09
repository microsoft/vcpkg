#
# vcpkg.mk - make variables and rules specific to Visual Studio
#

WindowsNT=1
x86Processor=1

BINDIR = bin
LIBDIR = lib

ABSTOP = $(shell cd $(TOP); pwd)

# Windows builds require a shared library build
BuildSharedLibrary=1
# This will be replaced

ThreadSystem=NT
undefine UnixPlatform
# Windows build requires static lib to generate symbol def file
undefine NoStaticLibrary
platform = Win32Platform

@build_info@

# Use the following set of flags to build and use multithreaded DLLs
#
MSVC_DLL_CXXNODEBUGFLAGS       = @VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE@
MSVC_DLL_CXXLINKNODEBUGOPTIONS = @VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_RELEASE@ -manifest
MSVC_DLL_CNODEBUGFLAGS         = @VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE@
MSVC_DLL_CLINKNODEBUGOPTIONS   = @VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_RELEASE@ -manifest
#
MSVC_DLL_CXXDEBUGFLAGS         = @VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG@ -D_DEBUG
MSVC_DLL_CXXLINKDEBUGOPTIONS   = @VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_DEBUG@ -manifest
MSVC_DLL_CDEBUGFLAGS           = @VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG@ -D_DEBUG
MSVC_DLL_CLINKDEBUGOPTIONS     = @VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_DEBUG@ -manifest
#
# Or
#
# Use the following set of flags to build and use multithread static libraries
#
MSVC_STATICLIB_CXXNODEBUGFLAGS       = @VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE@
MSVC_STATICLIB_CXXLINKNODEBUGOPTIONS = @VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_RELEASE@ -manifest
MSVC_STATICLIB_CNODEBUGFLAGS         = @VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE@
MSVC_STATICLIB_CLINKNODEBUGOPTIONS   = @VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_RELEASE@ -manifest

MSVC_STATICLIB_CXXDEBUGFLAGS         = @VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG@ -D_DEBUG
MSVC_STATICLIB_CXXLINKDEBUGOPTIONS   = @VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_DEBUG@ -manifest
MSVC_STATICLIB_CDEBUGFLAGS           = @VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG@ -D_DEBUG
MSVC_STATICLIB_CLINKDEBUGOPTIONS     = @VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_DEBUG@ -manifest

#
# Include general win32 things
#

include $(THIS_IMPORT_TREE)/mk/win32.mk

MANIFESTTOOL = @VCPKG_DETECTED_CMAKE_MT@
RCTOOL       = @VCPKG_DETECTED_CMAKE_RC_COMPILER@
CLINK        = @VCPKG_DETECTED_CMAKE_LINKER@
CXXLINK      = @VCPKG_DETECTED_CMAKE_LINKER@
AR           = @VCPKG_DETECTED_CMAKE_AR@
RANLIB       = true

# To build ZIOP support, EnableZIOP must be defined and one or both of
# the zlib and zstd sections must be defined.

#EnableZIOP = 1

#EnableZIOPZLib = 1
#ZLIB_ROOT = /cygdrive/c/zlib-1.2.11
#ZLIB_CPPFLAGS = -DOMNI_ENABLE_ZIOP_ZLIB -I$(ZLIB_ROOT)
#ZLIB_LIB = $(patsubst %,$(LibPathPattern),$(ZLIB_ROOT)) zdll.lib

#EnableZIOPZStd = 1
#ZSTD_ROOT = /cygdrive/c/zstd
#ZSTD_CPPFLAGS = -DOMNI_ENABLE_ZIOP_ZSTD -I$(ZSTD_ROOT)/include
#ZSTD_LIB = $(patsubst %,$(LibPathPattern),$(ZSTD_ROOT)/lib) zstd.lib
LN_S=cp -pR 

define ExportSharedLibraryToDir
 $(ExportLibraryToDir); \
 $(ParseNameSpec); \
 soname=$(SharedLibraryShortLibName); \
 libname=$(SharedLibraryLibNameTemplate); \
 set -x; \
 cd $$dir; \
 $(RM) $$soname; \
 $(LN_S) $(<F) $$soname;
endef