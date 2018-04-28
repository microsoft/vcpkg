# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/restinio-0.4.5-vcpkg)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/ngrodzitski/restinio-vcpkg-archives-tesst-2018/downloads/restinio-0.4.5-vcpkg.zip"
    FILENAME "restinio-0.4.5-vcpkg.zip"
    SHA512 9a6b262ad3e27a14781c1f29e1d63efc8933bdf316682823e5313b6ee92add58143f65cf9db92d05365a1a587499531fb9b3aeb121c78d0ac4a04867dd54ca78
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/restinio")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restinio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/restinio/LICENSE ${CURRENT_PACKAGES_DIR}/share/restinio/copyright)
