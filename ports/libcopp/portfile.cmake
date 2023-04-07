vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owent/libcopp
    REF "v${VERSION}"
    SHA512 b2a944d826521dbbf481da3e8d072bb024a0894207b5d9759636959d98b75c1fb37db24f6651d108832bbb4379008d17b0cb4bfc3b6c6ba1c1fdcfbc96f68b82
    HEAD_REF v2
    PATCHES fix-x86-windows.patch
)

# atframework/cmake-toolset needed as a submodule for configure cmake
vcpkg_from_github(
  OUT_SOURCE_PATH ATFRAMEWORK_CMAKE_TOOLSET
  REPO atframework/cmake-toolset
  REF v1.10.1
  SHA512 7ea18e41fabd35af5fd72fb954a1c60480ba85a9ff820104785d263e719751ba699eeca801ce5155041d8bf51fb2c37ea53f6ed404e4a4e7e810f1eb9bacead4
  HEAD_REF main
  )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS "-DATFRAMEWORK_CMAKE_TOOLSET_DIR=${ATFRAMEWORK_CMAKE_TOOLSET}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/BOOST_LICENSE_1_0.txt" "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libcopp)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libcopp/libcopp-config.cmake" "set(\${CMAKE_FIND_PACKAGE_NAME}_SOURCE_DIR \"${SOURCE_PATH}\")" "")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
