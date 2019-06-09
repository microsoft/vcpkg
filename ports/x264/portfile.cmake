include(vcpkg_common_functions)

set(X264_VERSION 157)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/x264
    REF 303c484ec828ed0d8bfe743500e70314d026c3bd
    SHA512 faf210a3f9543028ed882c8348b243dd7ae6638e7b3ef43bec1326b717f23370f57c13d0ddb5e1ae94411088a2e33031a137b68ae9f64c18f8f33f601a0da54d
    HEAD_REF master
    PATCHES 
        "uwp-cflags.patch"
)

# Acquire tools
vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.15)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86 OR VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")
endif()

# Insert msys into the path between the compiler toolset and windows system32. This prevents masking of "link.exe" but DOES mask "find.exe".
string(REPLACE ";$ENV{SystemRoot}\\system32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
set(ENV{PATH} "${NEWPATH}")
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

set(AUTOMAKE_DIR ${MSYS_ROOT}/usr/share/automake-1.15)
#file(COPY ${AUTOMAKE_DIR}/config.guess ${AUTOMAKE_DIR}/config.sub DESTINATION ${SOURCE_PATH}/source)

set(CONFIGURE_OPTIONS "--host=i686-pc-mingw32 --enable-strip --disable-lavf --disable-swscale --disable-avs --disable-ffms --disable-gpac --disable-lsmash")

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x86 AND NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --disable-asm")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-shared")
    if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --extra-ldflags=-APPCONTAINER --extra-ldflags=WindowsApp.lib")
    endif()
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(ENV{LIBPATH} "$ENV{LIBPATH};$ENV{_WKITS10}references\\windows.foundation.foundationcontract\\2.0.0.0\\;$ENV{_WKITS10}references\\windows.foundation.universalapicontract\\3.0.0.0\\")
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP --extra-cflags=-D_WIN32_WINNT=0x0A00")
endif()

set(CONFIGURE_OPTIONS_RELEASE "--prefix=${CURRENT_PACKAGES_DIR}")
set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --prefix=${CURRENT_PACKAGES_DIR}/debug")

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(X264_RUNTIME "-MT")
else()
    set(X264_RUNTIME "-MD")
endif()

# Configure release
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
set(ENV{CFLAGS} "${X264_RUNTIME} -O2 -Oi -Zi")
set(ENV{CXXFLAGS} "${X264_RUNTIME} -O2 -Oi -Zi")
set(ENV{LDFLAGS} "-DEBUG -INCREMENTAL:NO -OPT:REF -OPT:ICF")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c 
        "CC=cl ${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELEASE}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME "configure-${TARGET_TRIPLET}-rel")
message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

# Configure debug
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
set(ENV{CFLAGS} "${X264_RUNTIME}d -Od -Zi -RTC1")
set(ENV{CXXFLAGS} "${X264_RUNTIME}d -Od -Zi -RTC1")
set(ENV{LDFLAGS} "-DEBUG")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c 
        "CC=cl ${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    LOGNAME "configure-${TARGET_TRIPLET}-dbg")
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")

unset(ENV{CFLAGS})
unset(ENV{CXXFLAGS})
unset(ENV{LDFLAGS})

# Build release
message(STATUS "Package ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make && make install"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME "build-${TARGET_TRIPLET}-rel")
message(STATUS "Package ${TARGET_TRIPLET}-rel done")

# Build debug
message(STATUS "Package ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make && make install"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    LOGNAME "build-${TARGET_TRIPLET}-dbg")
message(STATUS "Package ${TARGET_TRIPLET}-dbg done")

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/x264)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/x264.exe ${CURRENT_PACKAGES_DIR}/tools/x264/x264.exe)
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/bin/x264.exe
    ${CURRENT_PACKAGES_DIR}/debug/include
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libx264.dll.lib ${CURRENT_PACKAGES_DIR}/lib/libx264.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libx264.dll.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libx264.lib)
else()
    # force U_STATIC_IMPLEMENTATION macro
    file(READ ${CURRENT_PACKAGES_DIR}/include/x264.h HEADER_CONTENTS)
    string(REPLACE "defined(U_STATIC_IMPLEMENTATION)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/x264.h "${HEADER_CONTENTS}")

    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/x264)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/x264/COPYING ${CURRENT_PACKAGES_DIR}/share/x264/copyright)
