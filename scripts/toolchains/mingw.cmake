# http://www.cmake.org/Wiki/CMake_Cross_Compiling#The_toolchain_file
# Help improve and optimize

SET(IS_CROSSCOMPILING "YES")
SET(CMAKE_SYSTEM_VERSION 1)

#SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
#SET(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

#Detect .vcpkg-root to figure VCPKG_ROOT_DIR
SET(VCPKG_ROOT_DIR_CANDIDATE ${CMAKE_CURRENT_LIST_DIR})
while(IS_DIRECTORY ${VCPKG_ROOT_DIR_CANDIDATE} AND NOT EXISTS "${VCPKG_ROOT_DIR_CANDIDATE}/.vcpkg-root")
    get_filename_component(VCPKG_ROOT_DIR_TEMP ${VCPKG_ROOT_DIR_CANDIDATE} DIRECTORY)
    if (VCPKG_ROOT_DIR_TEMP STREQUAL VCPKG_ROOT_DIR_CANDIDATE) # If unchanged, we have reached the root of the drive
        message(FATAL_ERROR "Could not find .vcpkg-root")
    else()
        SET(VCPKG_ROOT_DIR_CANDIDATE ${VCPKG_ROOT_DIR_TEMP})
    endif()
endwhile()

set(VCPKG_ROOT_DIR ${VCPKG_ROOT_DIR_CANDIDATE})

if(DEFINED ENV{MSYS_ROOT})
    set(MSYS_ROOT "${MSYS_ROOT}")
else()
    set(MSYS_ROOT "${VCPKG_ROOT_DIR}/downloads/tools/msys2/msys64")
	# Example full path
	# set(MSYS_ROOT "I:/msys2")
endif()

if(NOT _VCPKG_MINGW_TOOLCHAIN)
SET(_VCPKG_MINGW_TOOLCHAIN 1)
get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if(NOT _CMAKE_IN_TRY_COMPILE)

if (VCPKG_TARGET_TRIPLET MATCHES mingw32)
    set(CMAKE_SYSTEM_PROCESSOR i686)
    set(BITS 32)
	set(MSYSTEM MINGW32)

	set(CARCH "i686")
	set(CHOST "i686-w64-mingw32")
	set(MINGW_CHOST "i686-w64-mingw32")
	set(MINGW_PREFIX "/mingw32")
	set(MINGW_PACKAGE_PREFIX "mingw-w64-i686")
	
elseif (VCPKG_TARGET_TRIPLET MATCHES mingw64)
    set(CMAKE_SYSTEM_PROCESSOR	x86_64)
    set(BITS	64)
	set(MSYSTEM	MINGW64)
	set(CARCH	"x86_64")
	set(CHOST	"x86_64-w64-mingw32")
	set(MINGW_CHOST	"x86_64-w64-mingw32")
	set(MINGW_PREFIX	"/mingw64")
	set(MINGW_PACKAGE_PREFIX	"mingw-w64-x86_64")
endif ()

set(ENV{PATH} "${MSYS_ROOT}/mingw${BITS}/${MINGW_CHOST};${MSYS_ROOT}/mingw${BITS}/bin;${MSYS_ROOT}/usr/bin;$ENV{PATH}")

SET(CROSS_COMPILE_TOOLCHAIN_PATH "${MSYS_ROOT}/mingw${BITS}/bin/")
SET(CROSS_COMPILE_TOOLCHAIN_PREFIX "${MINGW_CHOST}")
SET(CROSS_COMPILE_SYSROOT "${MSYS_ROOT}/mingw${BITS}/${MINGW_CHOST}/")

SET(COMPILE_TOOLCHAIN_PATH "${MSYS_ROOT}/mingw${BITS}/bin/")
SET(COMPILE_TOOLCHAIN_PREFIX "${MINGW_CHOST}")

SET(BASH "${MSYS_ROOT}/mingw${BITS}/bin/bash.exe")

# which compilers to use for C and C++
# specify the cross linker

#find_program(CMAKE_RC_COMPILER NAMES ${MINGW_CHOST}-windres)
#find_program(CMAKE_C_COMPILER NAMES ${MINGW_CHOST}-gcc)
#find_program(CMAKE_MAKE_PROGRAM NAMES "mingw32-make.exe")
#find_program(CMAKE_C_COMPILER NAMES "${MINGW_CHOST}-gcc.exe")
#find_program(CMAKE_CXX_LINK_EXECUTABLE NAMES "${MINGW_CHOST}-g++.exe")
#find_program(CMAKE_AR NAMES "${MINGW_CHOST}-gcc-ar.exe")
#find_program(CMAKE_NM NAMES "${MINGW_CHOST}-gcc-nm.exe")
#find_program(CMAKE_RANLIB NAMES "${MINGW_CHOST}-gcc-ranlib.exe")
#find_program(CMAKE_CXX_LINK_EXECUTABLE NAMES "ld.exe")
#find_program(CMAKE_Fortran_COMPILER NAMES "gfortran.exe")

#SET(CMAKE_RC_COMPILER	"${MSYS_ROOT}/mingw${BITS}/bin/${MINGW_CHOST}-windres.exe")
#SET(CMAKE_Fortran_COMPILER	"${MSYS_ROOT}/mingw${BITS}/bin/gfortran.exe")
#SET(CMAKE_C_COMPILER	"${MSYS_ROOT}/mingw${BITS}/bin/${MINGW_CHOST}-gcc.exe")
#SET(CMAKE_CXX_COMPILER	"${MSYS_ROOT}/mingw${BITS}/bin/${MINGW_CHOST}-g++.exe")
#SET(CMAKE_CXX_LINK_EXECUTABLE	"${MSYS_ROOT}/mingw${BITS}/bin/${MINGW_CHOST}-g++.exe")
#SET(CMAKE_AR	"${MSYS_ROOT}/mingw${BITS}/bin/${MINGW_CHOST}-gcc-ar.exe")
#SET(CMAKE_NM	"${MSYS_ROOT}/mingw${BITS}/bin/${MINGW_CHOST}-gcc-nm.exe")
#SET(CMAKE_RANLIB	"${MINGW_CHOST}-gcc-ranlib.exe")
#SET(CMAKE_ASM-ATT_COMPILER	"${MINGW_CHOST}-as.exe")

#SET(COLLECT_GCC	x86_64-w64-mingw32-gcc)
#SET(COLLECT_LTO_WRAPPER	lto-wrapper)

# Crosscompiler path
SET(USER_ROOT_PATH	"${MSYS_ROOT}/mingw${BITS}/opt/${MINGW_CHOST}")
SET(CMAKE_FIND_ROOT_PATH 
	"${USER_ROOT_PATH}"
	"${MSYS_ROOT}/mingw${BITS}"
	"${MSYS_ROOT}/mingw${BITS}/${MINGW_CHOST}"
)

SET(CMAKE_PREFIX_PATH 
	"${MSYS_ROOT}/mingw${BITS}"
	"${MSYS_ROOT}/mingw${BITS}/${MINGW_CHOST}"
#	"${CURRENT_INSTALLED_DIR}"
)

# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
# search headers and libraries in the target environment, search 
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

#SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
#SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
#SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)

# Directories where to search for DLLs
SET(DLL_SEARCH_PATH
    "${MINGW_PREFIX}/lib"
    "${MINGW_PREFIX}/bin"
    "${MINGW_PREFIX}/bin/qt-plugins/plugins"
)

SET(wintool Win32)

#SET(QT_LIBRARY_DIR	${MINGW_PREFIX}/lib)
#SET(QT_MKSPECS_DIR	${MINGW_PREFIX}/mkspecs)

#SET(QT_LIBRARY_DIR	/Qt/lib)
#SET(QT_HEADERS_DIR	/Qt/include)  --  /usr/i686-pc-mingw32/Qt/include
#SET(QT_MKSPECS_DIR	/Qt/mkspecs)
#SET(QT_DOCS_DIR	/Qt/doc)
#SET(QT_PLUGINS_DIR	/Qt/plugins)

# Modules
#SET(QT_INCLUDE_DIR              ${MINGW_PREFIX}/include)
#SET(QT_QTCORE_INCLUDE_DIR       ${MINGW_PREFIX}/include/QtCore)
#SET(QT_QTGUI_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtGui)
#SET(QT_QTNETWORK_INCLUDE_DIR    ${MINGW_PREFIX}/include/QtNetwork)
#SET(QT_QTWEBKIT_INCLUDE_DIR     ${MINGW_PREFIX}/include/QtWebKit)
#SET(QT_QTSQL_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtSql)
#SET(QT_QTXML_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtXml)
#SET(QT_PHONON_INCLUDE_DIR		${MINGW_PREFIX}/include/phonon)


endif()
endif()




