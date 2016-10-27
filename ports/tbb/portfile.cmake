# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
endif()
include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tbb2017_20160916oss)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.threadingbuildingblocks.org/sites/default/files/software_releases/windows/tbb2017_20160916oss_win_1.zip"
    FILENAME "tbb2017_20160916oss_win_1.zip"
    SHA512 14bbc54aa0c4506bab6e6fdb7e9e562cbc88881cb683a8bd690e3101177e55433f25a2143e7af1ed52edacb44dc92fab354e1f2101bc13b33b3ea137def8bdd1
)
vcpkg_extract_source_archive(${ARCHIVE})

# Installation
message(STATUS "Installing")
file(COPY
  ${SOURCE_PATH}/include/tbb
  ${SOURCE_PATH}/include/serial
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(BIN_PATH ${SOURCE_PATH}/bin/intel64/vc14)
  set(LIB_PATH ${SOURCE_PATH}/lib/intel64/vc14)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(BIN_PATH ${SOURCE_PATH}/bin/ia32/vc14)
  set(LIB_PATH ${SOURCE_PATH}/lib/ia32/vc14)
else()
  message(FATAL_ERROR "Unsupported architecture")
endif()

file(COPY
  ${LIB_PATH}/tbb.lib
  ${LIB_PATH}/tbb_preview.lib
  ${LIB_PATH}/tbbmalloc.lib
  ${LIB_PATH}/tbbmalloc_proxy.lib
  ${LIB_PATH}/tbbproxy.lib
  ${LIB_PATH}/tbbproxy.pdb
  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY
  ${LIB_PATH}/tbb_debug.lib
  ${LIB_PATH}/tbb_preview_debug.lib
  ${LIB_PATH}/tbbmalloc_debug.lib
  ${LIB_PATH}/tbbmalloc_proxy_debug.lib
  ${LIB_PATH}/tbbproxy_debug.lib
  ${LIB_PATH}/tbbproxy_debug.pdb
  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY
  ${BIN_PATH}/tbb.dll
  ${BIN_PATH}/tbb_preview.dll
  ${BIN_PATH}/tbbmalloc.dll
  ${BIN_PATH}/tbbmalloc_proxy.dll
  ${BIN_PATH}/tbb.pdb
  ${BIN_PATH}/tbb_preview.pdb
  ${BIN_PATH}/tbbmalloc.pdb
  ${BIN_PATH}/tbbmalloc_proxy.pdb
  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY
  ${BIN_PATH}/tbb_debug.dll
  ${BIN_PATH}/tbb_preview_debug.dll
  ${BIN_PATH}/tbbmalloc_debug.dll
  ${BIN_PATH}/tbbmalloc_proxy_debug.dll
  ${BIN_PATH}/tbb_debug.pdb
  ${BIN_PATH}/tbb_preview_debug.pdb
  ${BIN_PATH}/tbbmalloc_debug.pdb
  ${BIN_PATH}/tbbmalloc_proxy_debug.pdb
  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

message(STATUS "Installing done")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tbb/LICENSE ${CURRENT_PACKAGES_DIR}/share/tbb/copyright)
