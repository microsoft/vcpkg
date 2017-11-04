# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)

set(VERSION 1.6.3)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/apr-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/apr/apr-${VERSION}.tar.bz2"
    FILENAME "apr-${VERSION}.tar.bz2"
    SHA512 f6b8679ae7fafff793c825c78775c84a646267c441710a50664589850e13148719b4eab48ab6e7c95b7aed085cff831115687434a7b160dcc2faa0eae63ac996
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DINSTALL_PDB=OFF -DMIN_WINDOWS_VER=Windows7 -DAPR_HAVE_IPV6=ON
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# There is no way to suppress installation of the headers in debug builds.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Both dynamic and static are built, so keep only the one needed
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/apr-1.lib
                ${CURRENT_PACKAGES_DIR}/lib/aprapp-1.lib
                ${CURRENT_PACKAGES_DIR}/debug/lib/apr-1.lib
                ${CURRENT_PACKAGES_DIR}/debug/lib/aprapp-1.lib)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libapr-1.lib
                ${CURRENT_PACKAGES_DIR}/lib/libaprapp-1.lib
                ${CURRENT_PACKAGES_DIR}/debug/lib/libapr-1.lib
                ${CURRENT_PACKAGES_DIR}/debug/lib/libaprapp-1.lib)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/apr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/apr/LICENSE ${CURRENT_PACKAGES_DIR}/share/apr/copyright)

vcpkg_copy_pdbs()
