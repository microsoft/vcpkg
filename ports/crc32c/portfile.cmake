include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/crc32c
  REF 83c31e797274a5b26e9e4a5355ba394cd0cabc10
  SHA512 829f8618c2769d274b400cf6de1dd2ab874d50d36e8cb086238aadae804154360b113faecd3c60e029a8d5ebc620d4b7cc7e1492775a4235d53989116227cd52
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Crc32c)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/crc32c RENAME copyright)
