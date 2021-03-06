vcpkg_fail_port_install(
    ON_TARGET "OSX" "iOS" "Linux" "Android" "UWP"
)

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
# vcpkg_fail_port_install(MESSAGE "winflexbison currently only supports Linux and Mac platforms" ON_TARGET "Windows")

set(VERSION 2.5.24)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexxmark/winflexbison
    REF v${VERSION}
    SHA512 a681f15dce23a39d1daea287f1c451fdc06d37bee27ac8329f44e254cffa7a435439d2b25401f70efe6d3d59bb49ebfc59a1355c4c0b8ae5fd81d6b4d39f971f
    HEAD_REF master
)

# # Check if one or more features are a part of a package installation.
# # See /docs/maintainers/vcpkg_check_features.md for more details
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
#   FEATURES # <- Keyword FEATURES is required because INVERTED_FEATURES are being used
#     tbb   WITH_TBB
#   INVERTED_FEATURES
#     tbb   ROCKSDB_IGNORE_PACKAGE_TBB
# )

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DCMAKE_INSTALL_PREFIX=${CURRENT_INSTALLED_DIR}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_cmake_build()

if(NOT DEFINED VCPKG_BUILD_TYPE)
    set(VCPKG_BUILD_TYPE release)
endif()

foreach(buildtype IN ITEMS debug release)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL buildtype)
        if(buildtype STREQUAL "debug")
            set(src_path ${SOURCE_PATH}/bin/Debug)
        else()
            set(src_path ${SOURCE_PATH}/bin/Release)
        endif()

        set(pack_path ${CURRENT_PACKAGES_DIR}/tools/${PORT})

        file(GLOB TO_INSTALL ${src_path}/*)

        foreach(file IN LISTS TO_INSTALL)
            file(COPY ${file} DESTINATION ${pack_path})
        endforeach()
    endif()
endforeach()

file(INSTALL ${SOURCE_PATH}/flex/src/FlexLexer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/winflexbison RENAME copyright)
