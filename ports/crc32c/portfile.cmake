include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/crc32c
  REF 1.0.6
  SHA512 c30f6510d6348f15dcdddc06e375f21a69681cd615483d67628b32de747e5e98200fa49faf7e3fc30a1302991fd1f9c9a706c9eb4e13c9c6c09e74066474ea7b
  HEAD_REF master
  PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001_export_symbols.patch
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
