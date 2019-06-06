# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lzo-2.10)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz"
    FILENAME "lzo-2.10.tar.gz"
    SHA512 a3dae5e4a6b93b1f5bf7435e8ab114a9be57252e9efc5dd444947d7a2d031b0819f34bcaeb35f60b5629a01b1238d738735a64db8f672be9690d3c80094511a4
)
vcpkg_extract_source_archive(${ARCHIVE})

set(LZO_STATIC OFF)
set(LZO_SHARED OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(LZO_STATIC ON)
else()
    set(LZO_SHARED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_STATIC=${LZO_STATIC}
        -DENABLE_SHARED=${LZO_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/libexec)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/libexec)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/lzo/lzoconf.h LZO_CONFIG)
    string(REPLACE "#  define __LZO_EXPORT1         /*empty*/"
                   "#  define __LZO_EXPORT1         __declspec(dllimport)" LZO_CONFIG "${LZO_CONFIG}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/lzo/lzoconf.h "${LZO_CONFIG}")
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/lzo)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/lzo/COPYING ${CURRENT_PACKAGES_DIR}/share/lzo/copyright)
