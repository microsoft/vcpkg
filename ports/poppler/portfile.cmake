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
# vcpkg_fail_port_install(MESSAGE "poppler currently only supports Linux and Mac platforms" ON_TARGET "Windows")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/freedesktop/poppler/archive/poppler-20.11.0.tar.gz"
    FILENAME "poppler-20.11.0.tar.gz"
    SHA512 debabdfade202f677ae10648f6f7c7de409420fc1f4e4168dce07617e1d2c90e191f38abab289de5522ba6abd57e9f4911bce10912861df26a4d79115214e474
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

file(GLOB bin_files ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${bin_files})

file(GLOB bin_files ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(REMOVE ${bin_files})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Moves all .cmake files from /debug/share/poppler/ to /share/poppler/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/poppler)

# # Fix the pkgconfig file for debug
# if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
#     if(VCPKG_TARGET_IS_WINDOWS)
#         vcpkg_replace_string(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/poppler.pc "-lpoppler" "-lpoppler-d")
#     elseif(VCPKG_TARGET_IS_LINUX)
#         vcpkg_replace_string(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/poppler.pc "-lpoppler" "-lpoppler-d")    
#     endif()
#     file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/poppler.pc DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
# endif()

# # Fix the pkgconfig file for release
# if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
#     if(VCPKG_TARGET_IS_WINDOWS)	
#         vcpkg_replace_string(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/poppler.pc "-lpoppler" "-lpoppler")
#     elseif(VCPKG_TARGET_IS_LINUX)
#         vcpkg_replace_string(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/poppler.pc "-lpoppler" "-lpoppler")
#     endif()
# 	file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/poppler.pc DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
# endif()
# if(VCPKG_TARGET_IS_WINDOWS)	
#     vcpkg_fixup_pkgconfig()
# elseif(VCPKG_TARGET_IS_LINUX)
#     vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread dl c)
# endif()

# # Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/poppler RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)