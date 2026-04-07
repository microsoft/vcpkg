vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO dacap/clip
  REF v${VERSION}
  SHA512 d245781ae4e290f75195782522190fc4d7645b8718d640fb5e3f6f7a47d1bcbf29fb34407b4368698dfe0039abfc42eac805201a192ab4569a68eca6f6234c76
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
