# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lsqlite3_fsl09x)
vcpkg_download_distfile(ARCHIVE
    URLS "http://lua.sqlite.org/index.cgi/zip/lsqlite3_fsl09x.zip?uuid=fsl_9x"
    FILENAME "lsqlite3_fsl09x.zip"
    SHA512 d05c3b5dd3c66cd7fe5189385da2fb6ad8662b84828c8179e7ebbc6dc22272e4d47cf6561e26bcae421b1db1867a1643832dbd99539a0a9c8163a7c0012ef9e7
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
     MESSAGE(FATAL_ERROR " static linkage is not supported for lua module.")
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# dummy include to satisfy vcpkg lint
file(WRITE ${CURRENT_PACKAGES_DIR}/include/lsqlite3.h "")

# Handle copyright
file(COPY ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/lua-lsqlite3/copyright)
