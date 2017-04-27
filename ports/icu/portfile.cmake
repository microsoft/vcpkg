if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/icu-59.1/icu)
set(ICU_VERSION 59)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.icu-project.org/files/icu4c/59.1/icu4c-59_1-src.zip"
    FILENAME "icu4c-59_1-src.zip"
    SHA512 1d3b39678e7cc4e9794e724982886a4918642231048eb76b9f683aad5a19e0b7c52b3b9c7107cb1a3879464682c4a3a97b58ab012d082bd9e5a80c67adf8ce8b)
vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src/icu-59.1)

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/disable-escapestr-tool.patch)

# Acquire tools
vcpkg_acquire_msys(MSYS_ROOT)

# Insert msys into the path between the compiler toolset and windows system32. This prevents masking of "link.exe" but DOES mask "find.exe".
string(REPLACE ";$ENV{SystemRoot}\\system32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
string(REPLACE ";$ENV{SystemRoot}\\System32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "${NEWPATH}")
set(ENV{PATH} "${NEWPATH}")
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "pacman -Sy --noconfirm --needed make automake1.15"
    WORKING_DIRECTORY "${MSYS_ROOT}"
    LOGNAME "pacman-${TARGET_TRIPLET}")

set(AUTOMAKE_DIR ${MSYS_ROOT}/usr/share/automake-1.15)
file(COPY ${AUTOMAKE_DIR}/config.guess ${AUTOMAKE_DIR}/config.sub DESTINATION ${SOURCE_PATH}/source)

set(CONFIGURE_OPTIONS "--host=i686-pc-mingw32 --disable-samples --disable-tests")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --disable-static --enable-shared")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static --disable-shared")
endif()

set(CONFIGURE_OPTIONS_RELASE "--disable-debug --enable-release --prefix=${CURRENT_PACKAGES_DIR}")
set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --disable-release --prefix=${CURRENT_PACKAGES_DIR}/debug")

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(ICU_RUNTIME "-MT")
else()
    set(ICU_RUNTIME "-MD")
endif()

# Configure release
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
set(ENV{CFLAGS} "${ICU_RUNTIME} -O2 -Oi -Zi")
set(ENV{CXXFLAGS} "${ICU_RUNTIME} -O2 -Oi -Zi")
set(ENV{LDFLAGS} "-DEBUG -INCREMENTAL:NO -OPT:REF -OPT:ICF")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c 
        "${SOURCE_PATH}/source/runConfigureICU MSYS/MSVC ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELASE}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME "configure-${TARGET_TRIPLET}-rel")
message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

# Configure debug
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
set(ENV{CFLAGS} "${ICU_RUNTIME}d -Od -Zi -RTC1")
set(ENV{CXXFLAGS} "${ICU_RUNTIME}d -Od -Zi -RTC1")
set(ENV{LDFLAGS} "-DEBUG")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c 
        "${SOURCE_PATH}/source/runConfigureICU MSYS/MSVC ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
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

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/share
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/lib/icu
    ${CURRENT_PACKAGES_DIR}/debug/lib/icud)

file(GLOB TEST_LIBS
    ${CURRENT_PACKAGES_DIR}/lib/*test*
    ${CURRENT_PACKAGES_DIR}/debug/lib/*test*)
file(REMOVE ${TEST_LIBS})

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    # copy icu dlls from lib to bin
    file(GLOB RELEASE_DLLS ${CURRENT_PACKAGES_DIR}/lib/icu*${ICU_VERSION}.dll)
    file(GLOB DEBUG_DLLS ${CURRENT_PACKAGES_DIR}/debug/lib/icu*d${ICU_VERSION}.dll)
    file(COPY ${RELEASE_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    # rename static libraries to match import libs
    # see https://gitlab.kitware.com/cmake/cmake/issues/16617
    foreach(MODULE dt in io tu uc)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/sicu${MODULE}.lib ${CURRENT_PACKAGES_DIR}/lib/icu${MODULE}.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/sicu${MODULE}d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/icu${MODULE}d.lib)
    endforeach()

    # force U_STATIC_IMPLEMENTATION macro
    foreach(HEADER utypes.h utf_old.h platform.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/unicode/${HEADER} HEADER_CONTENTS)
        string(REPLACE "defined(U_STATIC_IMPLEMENTATION)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/unicode/${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

# remove any remaining dlls in /lib
file(GLOB DUMMY_DLLS ${CURRENT_PACKAGES_DIR}/lib/*.dll ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
if(DUMMY_DLLS)
    file(REMOVE ${DUMMY_DLLS})
endif()

# Generates warnings about missing pdbs for icudt.dll
# This is expected because ICU database contains no executable code
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/icu)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/icu/LICENSE ${CURRENT_PACKAGES_DIR}/share/icu/copyright)
