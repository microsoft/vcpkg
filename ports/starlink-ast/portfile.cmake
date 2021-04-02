# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
#   DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   VCPKG_TOOLCHAIN           = ON OFF
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   BUILD_ARCH                = "Win32" "x64" "ARM"
#   MSBUILD_PLATFORM          = "Win32"/"x64"/${TRIPLET_SYSTEM_ARCH}
#   DEBUG_CONFIG              = "Debug Static" "Debug Dll"
#   RELEASE_CONFIG            = "Release Static"" "Release DLL"
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_LINUX
#   VCPKG_TARGET_IS_OSX
#   VCPKG_TARGET_IS_FREEBSD
#   VCPKG_TARGET_IS_ANDROID
#   VCPKG_TARGET_IS_MINGW
#   VCPKG_TARGET_EXECUTABLE_SUFFIX
#   VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
#   VCPKG_TARGET_SHARED_LIBRARY_SUFFIX
#
# 	See additional helpful variables in /docs/maintainers/vcpkg_common_definitions.md

# # Specifies if the port install should fail immediately given a condition
# vcpkg_fail_port_install(MESSAGE "starlink-ast currently only supports Linux and Mac platforms" ON_TARGET "Windows")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Starlink/ast/releases/download/v9.2.3/ast-9.2.3.tar.gz"
    FILENAME "ast-9.2.3.tar.gz"
    SHA512 5cd19d153381a22f7a250189321b9914b52ec05e057b48aa735477e414c6b1b535135bfdd72049aaf1ed245b8b9ff2a8664b3fb1d374429d89bab786b491e74e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    # REF 1.0.0
    # (Optional) Read the docs for how to generate patches at:
    # https://github.com/Microsoft/vcpkg/blob/master/docs/examples/patching.md
    # PATCHES
    #   001_port_fixes.patch
    #   002_more_port_fixes.patch
)


set(CONFIGURE_OPTIONS "--without-fortran --without-stardocs --without-pthreads --without-yaml")

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
    mesage(ERROR "TODO!")
else()

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=x86_64-w64-mingw32")
    else()
        set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=i686-w64-mingw32")
    endif()

    # Acquire tools
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.16)
    # Insert msys into the path between the compiler toolset and windows system32. This prevents masking of "link.exe" but DOES mask "find.exe".
    string(REPLACE ";$ENV{SystemRoot}\\system32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
    string(REPLACE ";$ENV{SystemRoot}\\System32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "${NEWPATH}")
    set(ENV{PATH} "${NEWPATH}")
    #set(ENV{PATH} "${MSYS_ROOT}/usr/bin;$ENV{PATH}")
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)    

    if(VCPKG_CRT_LINKAGE STREQUAL static)
        set(AST_CRT_LINKAGE --enable-static-msvcrt)
        set(LIBVPX_CRT_SUFFIX mt)
    else()
        set(LIBVPX_CRT_SUFFIX md)
    endif()

    if(NOT VCPKG_TARGET_IS_MINGW)
        set(PLATFORM "MSYS/MSVC")
        if(VCPKG_CRT_LINKAGE STREQUAL static)
            set(ICU_RUNTIME "-MT")
        else()
            set(ICU_RUNTIME "-MD")
        endif()
        set(EXTRA_RELEASE_FLAGS "${ICU_RUNTIME} -O2 -Oi -Zi -FS")
        set(RELEASE_LDFLAGS "-DEBUG -INCREMENTAL:NO -OPT:REF -OPT:ICF")
        set(EXTRA_DEBUG_FLAGS "${ICU_RUNTIME}d -Od -Zi -FS -RTC1")
        set(DEBUG_LDFLAGS "-DEBUG")
    else()
        set(PLATFORM "MinGW")
        set(ENV{CC} "${CMAKE_C_COMPILER}")
        set(ENV{CXX} "${CMAKE_CXX_COMPILER}")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        # Configure release
        message(STATUS "Configuring ${RELEASE_TRIPLET}")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
        set(ENV{CFLAGS} "${EXTRA_RELEASE_FLAGS} ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE}")
        set(ENV{CXXFLAGS} "${EXTRA_RELEASE_FLAGS} ${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_RELEASE}")
        set(ENV{LDFLAGS} "${RELEASE_LDFLAGS}")
        vcpkg_execute_required_process(
            COMMAND ${BASH} --noprofile --norc -c
                "${SOURCE_PATH}/configure CFLAGS=-DCMINPACK_NO_DLL --without-pthreads --without-fortran --without-stardocs --enable-shared=no"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}"
            LOGNAME "configure-${RELEASE_TRIPLET}")
        message(STATUS "Configuring ${RELEASE_TRIPLET} done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        # Configure debug
        message(STATUS "Configuring ${DEBUG_TRIPLET}")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
        set(ENV{CFLAGS} "${EXTRA_DEBUG_FLAGS} ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG}")
        set(ENV{CXXFLAGS} "${EXTRA_DEBUG_FLAGS} ${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_DEBUG}")
        set(ENV{LDFLAGS} "${DEBUG_LDFLAGS}")
        vcpkg_execute_required_process(
            COMMAND ${BASH} --noprofile --norc -c
                "${SOURCE_PATH}/configure ${AST_CRT_LINKAGE} ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}"
            LOGNAME "configure-${RELEASE_TRIPLET}")
        message(STATUS "Configuring ${DEBUG_TRIPLET} done")
    endif()
endif()

unset(ENV{CFLAGS})
unset(ENV{CXXFLAGS})
unset(ENV{LDFLAGS})

endif()

# # Check if one or more features are a part of a package installation.
# # See /docs/maintainers/vcpkg_check_features.md for more details
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
#   FEATURES # <- Keyword FEATURES is required because INVERTED_FEATURES are being used
#     tbb   WITH_TBB
#   INVERTED_FEATURES
#     tbb   ROCKSDB_IGNORE_PACKAGE_TBB
# )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# # Moves all .cmake files from /debug/share/starlink-ast/ to /share/starlink-ast/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/starlink-ast)

# # Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/starlink-ast RENAME copyright)
