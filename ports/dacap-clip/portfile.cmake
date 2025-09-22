vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO dacap/clip
  REF v${VERSION}
  SHA512 450653964c4c943daf47fca32f63d9de40aa6e2daf1cb96e3d71543d4919352adca3b6db529c4de985a72ec21166f97974484114d23e12ea73da31cc1d536481
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
