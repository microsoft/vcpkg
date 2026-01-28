vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO dacap/clip
  REF v${VERSION}
  SHA512 c372c18081f2a090e88e04b7253e891589aaa821f660aef603e14f3004aaeb5a4f9540bee1105da5b49f97ee027dd50e374a22cb43e5d7501cf7362661ce0c14
  PATCHES
    "fix-install-header-and-force-static-compilation.patch")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DCLIP_ENABLE_LIST_FORMATS=ON
    -DCLIP_EXAMPLES=OFF
    -DCLIP_TESTS=OFF
    -DCLIP_X11_WITH_PNG=ON
  MAYBE_UNUSED_VARIABLES
    CLIP_X11_WITH_PNG # only an option when UNIX AND NOT APPLE
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(PACKAGE_NAME clip CONFIG_PATH "lib/cmake/clip")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
