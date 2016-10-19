# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
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
file(COPY ${SOURCE_PATH}/bin DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

# Remove artefacts for other architectures
if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/bin/ia32)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/lib/ia32) 
else()
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/bin/intel64)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/lib/intel64)
endif()

vcpkg_copy_pdbs()

message(STATUS "Installing done")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tbb/LICENSE ${CURRENT_PACKAGES_DIR}/share/tbb/copyright)
