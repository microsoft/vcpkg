vcpkg_fail_port_install(ON_TARGET "uwp")

set(ICU_VERSION_MAJOR 67)
set(ICU_VERSION_MINOR 1)
set(VERSION "${ICU_VERSION_MAJOR}.${ICU_VERSION_MINOR}")
set(VERSION2 "${ICU_VERSION_MAJOR}_${ICU_VERSION_MINOR}")
set(VERSION3 "${ICU_VERSION_MAJOR}-${ICU_VERSION_MINOR}")

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/unicode-org/icu/releases/download/release-${VERSION3}/icu4c-${VERSION2}-src.tgz"
    FILENAME "icu4c-${VERSION2}-src.tgz"
    SHA512 4779f1ce1ca7976f6fad6768853ea8c540da54d11509e3b6cfd864a04b5f2db1c3d4b546387f91ad02fb90804525bc37d2543173f0d705d6ca11dc6f2b7640a8
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/disable-escapestr-tool.patch
        ${CMAKE_CURRENT_LIST_DIR}/remove-MD-from-configure.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix_parallel_build_on_windows.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-extra.patch
)

vcpkg_find_acquire_program(PYTHON3)
set(ENV{PYTHON} "${PYTHON3}")

set(CONFIGURE_OPTIONS "--disable-samples --disable-tests --disable-layoutex")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --disable-static --enable-shared")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static --disable-shared")
endif()

set(CONFIGURE_OPTIONS_RELEASE "--disable-debug --enable-release --prefix=${CURRENT_PACKAGES_DIR}")
set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --disable-release --prefix=${CURRENT_PACKAGES_DIR}/debug")
set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(BASH bash)
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -fPIC")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -fPIC")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        # Configure release
        message(STATUS "Configuring ${RELEASE_TRIPLET}")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
        set(ENV{CFLAGS} "-O2 ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE}")
        set(ENV{CXXFLAGS} "-O2 ${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_RELEASE}")
        vcpkg_execute_required_process(
            COMMAND ${BASH} --noprofile --norc -c
                "${SOURCE_PATH}/source/runConfigureICU Linux ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELEASE}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}"
            LOGNAME "configure-${RELEASE_TRIPLET}")
        message(STATUS "Configuring ${RELEASE_TRIPLET} done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        # Configure debug
        message(STATUS "Configuring ${DEBUG_TRIPLET}")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
        set(ENV{CFLAGS} "-O0 -g ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG}")
        set(ENV{CXXFLAGS} "-O0 -g ${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_DEBUG}")
        vcpkg_execute_required_process(
            COMMAND ${BASH} --noprofile --norc -c
                "${SOURCE_PATH}/source/runConfigureICU Linux ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET}"
            LOGNAME "configure-${DEBUG_TRIPLET}")
        message(STATUS "Configuring ${DEBUG_TRIPLET} done")
    endif()

else()

    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=i686-pc-mingw32")

    # Acquire tools
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.16)

    # Insert msys into the path between the compiler toolset and windows system32. This prevents masking of "link.exe" but DOES mask "find.exe".
    string(REPLACE ";$ENV{SystemRoot}\\system32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
    string(REPLACE ";$ENV{SystemRoot}\\System32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "${NEWPATH}")
    set(ENV{PATH} "${NEWPATH}")
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

    set(AUTOMAKE_DIR ${MSYS_ROOT}/usr/share/automake-1.16)
    file(COPY ${AUTOMAKE_DIR}/config.guess ${AUTOMAKE_DIR}/config.sub DESTINATION ${SOURCE_PATH}/source)

    if(VCPKG_CRT_LINKAGE STREQUAL static)
        set(ICU_RUNTIME "-MT")
    else()
        set(ICU_RUNTIME "-MD")
    endif()

    if(CMAKE_HOST_WIN32 AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64") AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
        set(ICU_MSVC_CROSS_COMPILE_TO_ARM ON)
        # Need the buildtrees dir, as the required files (e.g. icucross.mk) are not part of the installed package
        get_filename_component(ICU_HOST_PATH "${BUILDTREES_DIR}/icu/x86-windows-rel" ABSOLUTE)
        if(NOT EXISTS "${ICU_HOST_PATH}")
            message(FATAL_ERROR "The x86 icu must be be built locally to build for non-x86/x64 platforms. Please run `vcpkg install icu:x86-windows`.")
        endif()

        set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --with-cross-build=${ICU_HOST_PATH}")
        set(ENV{PATH} "$ENV{PATH}${VCPKG_HOST_PATH_SEPARATOR}${ICU_HOST_PATH}/lib")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        # Configure release
        message(STATUS "Configuring ${RELEASE_TRIPLET}")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
        set(ENV{CFLAGS} "${ICU_RUNTIME} -O2 -Oi -Zi -FS ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE}")
        set(ENV{CXXFLAGS} "${ICU_RUNTIME} -O2 -Oi -Zi -FS ${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_RELEASE}")
        set(ENV{LDFLAGS} "-DEBUG -INCREMENTAL:NO -OPT:REF -OPT:ICF")
        vcpkg_execute_required_process(
            COMMAND ${BASH} --noprofile --norc -c
                "${SOURCE_PATH}/source/runConfigureICU MSYS/MSVC ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELEASE}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}"
            LOGNAME "configure-${RELEASE_TRIPLET}")
        message(STATUS "Configuring ${RELEASE_TRIPLET} done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        # Configure debug
        message(STATUS "Configuring ${DEBUG_TRIPLET}")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
        set(ENV{CFLAGS} "${ICU_RUNTIME}d -Od -Zi -FS -RTC1 ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG}")
        set(ENV{CXXFLAGS} "${ICU_RUNTIME}d -Od -Zi -FS -RTC1 ${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_DEBUG}")
        set(ENV{LDFLAGS} "-DEBUG")
        vcpkg_execute_required_process(
            COMMAND ${BASH} --noprofile --norc -c
                "${SOURCE_PATH}/source/runConfigureICU MSYS/MSVC ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET}"
            LOGNAME "configure-${DEBUG_TRIPLET}")
        message(STATUS "Configuring ${DEBUG_TRIPLET} done")
    endif()
endif()

unset(ENV{CFLAGS})
unset(ENV{CXXFLAGS})
unset(ENV{LDFLAGS})

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    # Build release
    message(STATUS "Package ${RELEASE_TRIPLET}")
    vcpkg_execute_build_process(
        COMMAND ${BASH} --noprofile --norc -c "make -j ${VCPKG_CONCURRENCY}"
        NO_PARALLEL_COMMAND ${BASH} --noprofile --norc -c "make"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}"
        LOGNAME "make-build-${RELEASE_TRIPLET}")

    vcpkg_execute_build_process(
        COMMAND ${BASH} --noprofile --norc -c "make install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}"
        LOGNAME "make-install-${RELEASE_TRIPLET}")
    message(STATUS "Package ${RELEASE_TRIPLET} done")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    # Build debug
    message(STATUS "Package ${DEBUG_TRIPLET}")
    vcpkg_execute_build_process(
        COMMAND ${BASH} --noprofile --norc -c "make -j ${VCPKG_CONCURRENCY}"
        NO_PARALLEL_COMMAND ${BASH} --noprofile --norc -c "make"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET}"
        LOGNAME "make-build-${DEBUG_TRIPLET}")

    vcpkg_execute_build_process(
        COMMAND ${BASH} --noprofile --norc -c "make install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET}"
        LOGNAME "make-install-${DEBUG_TRIPLET}")
    message(STATUS "Package ${DEBUG_TRIPLET} done")
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/share
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/icu
    ${CURRENT_PACKAGES_DIR}/debug/lib/icud)

file(GLOB TEST_LIBS
    ${CURRENT_PACKAGES_DIR}/lib/*test*
    ${CURRENT_PACKAGES_DIR}/debug/lib/*test*)
file(REMOVE ${TEST_LIBS})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # copy icu dlls from lib to bin
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB RELEASE_DLLS ${CURRENT_PACKAGES_DIR}/lib/icu*${ICU_VERSION_MAJOR}.dll)
        file(COPY ${RELEASE_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB DEBUG_DLLS ${CURRENT_PACKAGES_DIR}/debug/lib/icu*d${ICU_VERSION_MAJOR}.dll)
        file(COPY ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
else()
    if(VCPKG_TARGET_IS_WINDOWS)
        # rename static libraries to match import libs
        # see https://gitlab.kitware.com/cmake/cmake/issues/16617
        foreach(MODULE dt in io tu uc)
            if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
                file(RENAME ${CURRENT_PACKAGES_DIR}/lib/sicu${MODULE}.lib ${CURRENT_PACKAGES_DIR}/lib/icu${MODULE}.lib)
            endif()

            if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
                file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/sicu${MODULE}d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/icu${MODULE}d.lib)
            endif()
        endforeach()

        file(GLOB_RECURSE pkg_files LIST_DIRECTORIES false ${CURRENT_PACKAGES_DIR}/*.pc)
        message(STATUS "${pkg_files}")
        foreach(pkg_file IN LISTS pkg_files)
            message(STATUS "${pkg_file}")
            file(READ ${pkg_file} PKG_FILE)
            string(REGEX REPLACE "-ls([^ \\t\\n]+)" "-l\\1" PKG_FILE "${PKG_FILE}" )
            file(WRITE ${pkg_file} "${PKG_FILE}")
        endforeach()
    endif()

    # force U_STATIC_IMPLEMENTATION macro
    foreach(HEADER utypes.h utf_old.h platform.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/unicode/${HEADER} HEADER_CONTENTS)
        string(REPLACE "defined(U_STATIC_IMPLEMENTATION)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/unicode/${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

# Install executables from ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/bin to /tools/icu
file(GLOB ICU_TOOLS ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/bin/*${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(INSTALL ${ICU_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

# remove any remaining dlls in /lib
file(GLOB DUMMY_DLLS ${CURRENT_PACKAGES_DIR}/lib/*.dll ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
if(DUMMY_DLLS)
    file(REMOVE ${DUMMY_DLLS})
endif()

# Generates warnings about missing pdbs for icudt.dll
# This is expected because ICU database contains no executable code
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread m)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
