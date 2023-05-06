vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF f924651b85cac47dbe15f51a4aa320461fc1d07b #2.3.1+20230331
  SHA512 519ca76a02da8faa4d07e6fc8a0db32c75c5b9abbe3584664037f02760e667e487248c0a445cd8ca5b0add0828cc1e0922a9c8a0aea52558d4fa083f6ae802f7
  HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUNASVG_BUILD_EXAMPLES=OFF
    -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lunasvg)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
