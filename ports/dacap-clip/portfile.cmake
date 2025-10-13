vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO dacap/clip
  REF v${VERSION}
  SHA512 8cbe79d6189449be2a96141f97514e393ab7baccdcf37727f6dd54a3d5dacfe293ede39690d62dd4b7d346876973227dd9e29e14c7e8ca928223e6459005284c
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
