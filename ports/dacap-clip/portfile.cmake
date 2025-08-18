vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO dacap/clip
  REF v1.10
  SHA512 a29531ef276650807233b635ecceaf408147e4e263268eaf8237d74c9a7641d28cda5c6d1eaad4dbe634e720a5969dd6cc82aaeffbc36e0c9598ded31e419ea6
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
