include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/crc32c
  REF 12a65bfb328fefae5c05879132676f702a3f68e8
  SHA512 610b7c54b0247edd2d37ec18db68c1f8a55b60b2fd3ddcede41e6321eb45d040f513cece493cbdc67e881065a643c4972126864811ff08b24aa7e82642e54f56
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCRC32C_BUILD_TESTS=OFF
    -DCRC32C_BUILD_BENCHMARKS=OFF
    -DCRC32C_USE_GLOG=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/Crc32c")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/crc32c RENAME copyright)
