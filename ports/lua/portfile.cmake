# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lua-5.3.3)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.lua.org/ftp/lua-5.3.3.tar.gz"
    FILENAME "lua-5.3.3.tar.gz"
    SHA512 7b8122ed48ea2a9faa47d1b69b4a5b1523bb7be67e78f252bb4339bf75e957a88c5405156e22b4b63ccf607a5407bf017a4cee1ce12b1aa5262047655960a3cc
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/lua)
vcpkg_copy_pdbs()
