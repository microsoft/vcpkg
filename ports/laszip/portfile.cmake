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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/laszip-src-3.2.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/LASzip/LASzip/releases/download/3.2.2/laszip-src-3.2.2.tar.gz"
    FILENAME "laszip-src-3.2.2.tar.gz"
    SHA512 e89707c0569c6435394a3a07ba5e6ea972d65cf793c157a698d1ec293f5477deccd613733cb544b907d6c1f13d0313f0d24ae7e5dddc426d7bdb9a7e58709cf8
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
    OPTIONS
        #-DLASZIP_BUILD_STATIC:BOOL=ON
        #-DLASZIP_DYN_LINK=1
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/laszip RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Remove laszip_api3 dll since it doesn't export functions properly during build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/laszip_api3.dll)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/laszip_api3.dll)
