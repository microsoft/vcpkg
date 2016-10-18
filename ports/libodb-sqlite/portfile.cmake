# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libodb-sqlite-2.4.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-sqlite-2.4.0.tar.gz"
    FILENAME "libodb-sqlite-2.4.0.tar.gz"
    SHA512 af16da7c82cf8845ca3b393fbd8957a92b05ebc925a5191f20d414ab558345850073cd9c46457d0ef0edfb12ebcb27f267b934c9c69ef598380242fe920c8577
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
)
vcpkg_build_cmake()
vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libodb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libodb/LICENSE ${CURRENT_PACKAGES_DIR}/share/libodb/copyright)