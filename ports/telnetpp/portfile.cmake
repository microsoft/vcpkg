if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF 281bea2251d288cd95dd2b85c663f725a7985fc5 # v2.1.2+
  SHA512 9e14e253de3f0080955e4723af3d631de0a74202d59faa96ce6c3cf315efc9df378680191bb059578af7a30d05e48d73c37958772c3a9a903a5ee1950e10f8b7
  HEAD_REF master
  PATCHES
    fix-build-error.patch
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
