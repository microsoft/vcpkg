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
#removes current source to prevent static builds from using patched source code
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src/CCfits)
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src/CCfits-2.5.tar.gz.extracted)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CCfits)

vcpkg_download_distfile(ARCHIVE
    URLS "https://heasarc.gsfc.nasa.gov/fitsio/ccfits/CCfits-2.5.tar.gz"
    FILENAME "CCfits-2.5.tar.gz"
    SHA512 63ab4d153063960510cf60651d5c832824cf85f937f84adc5390c7c2fb46eb8e9f5d8cda2554d79d24c7a4f1b6cf0b7a6e20958fb69920b65d7c362c0a5f26b5
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CCfits
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/dll_exports.patch"
    )
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/CCfits.dll ${CURRENT_PACKAGES_DIR}/bin/CCfits.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/CCfits.dll ${CURRENT_PACKAGES_DIR}/debug/bin/CCfits.dll)
endif()

# Remove duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ccfits RENAME copyright)
