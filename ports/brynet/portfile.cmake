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
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Alembic does not support dynamic linkage. Building statically.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(BRYNET_VERSION 0.9.0)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/brynet-${BRYNET_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/IronsDu/brynet/archive/v${BRYNET_VERSION}.zip"
    FILENAME "v${BRYNET_VERSION}.zip"
    SHA512 a39bdffe6bb9b93bd6f21da0d59b172c2956c5f9366716dff01027f59660ca4d28ee557a42caa93d93047e041438a1de42ed22c67a3c2124d105a63381ac3685
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/brynet-${BRYNET_VERSION}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brynet)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/brynet/LICENSE ${CURRENT_PACKAGES_DIR}/share/brynet/copyright)
# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brynet RENAME copyright)
