vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF 3c6a8e0eb5492b22be105864910739b9c54c1928 # v2.1.2+
  SHA512 41c124fc2cdc14a20ea9ce6783c55f1fb26910b55063cf286b3ea4778a0796532c71354cd7361487dd5a33866a346926290fb0dc301a0f0a9f3e5ea401af97b0
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
