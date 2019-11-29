if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF 8dc780579293153ad2ae9ad6943815c050d4c659
  SHA512 280a8e6c0392f5822b05968520d176d1510f00c12a2502f6039f4f1f78a558e61f825a231fb70b7de6fd21a18b24734eea3ba36a24b29f2a7e9856b1f4de5217
  HEAD_REF master
  PATCHES fix-build-error.patch
)

set(USE_ZLIB OFF)
if("zlib" IN_LIST FEATURES)
    set(USE_ZLIB ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  DISABLE_PARALLEL_CONFIGURE
  PREFER_NINJA
  OPTIONS
    -DGSL_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/include
    -DTELNETPP_WITH_ZLIB=${USE_ZLIB}
    -DTELNETPP_WITH_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/telnetpp)

vcpkg_copy_pdbs()

# Remove duplicate header files and CMake input file
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/telnetpp/version.hpp.in)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/telnetpp RENAME copyright)
