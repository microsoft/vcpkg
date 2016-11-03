# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/apr-1.5.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/apr/apr-1.5.2.tar.bz2"
    FILENAME "apr-1.5.2.tar.bz2"
    SHA512 d1156ad16abf07887797777b56c2147c890f16d8445829b3e3b4917950d24c5fd2f8febd439992467a5ea0511da562c0fb4a7cfd8a235ab55882388bfa2b919d
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

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/apr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/apr/LICENSE ${CURRENT_PACKAGES_DIR}/share/apr/copyright)
