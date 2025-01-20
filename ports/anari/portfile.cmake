set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/ANARI-SDK
  REF "v${VERSION}"
  SHA512 0a184fea1ab3afab72606d434d69cd3e171ae04d042fc6a425ba777c094af5a8225bb187a47176ac4afd6b2c57d0363f6e97e1f71b30137be09f26cc50590fac
  HEAD_REF next_release
  PATCHES anari-lib-maybe-static-lib.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_CTS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_HDANARI=OFF
    -DBUILD_HELIDE_DEVICE=OFF
    -DBUILD_REMOTE_DEVICE=OFF
    -DBUILD_TESTING=OFF
    -DBUILD_VIEWER=OFF
    -DINSTALL_CODE_GEN_SCRIPTS=ON
    -DINSTALL_VIEWER_LIBRARY=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
  CONFIG_PATH "lib/cmake/${PORT}-${VERSION}"
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_replace_string(
  "${CURRENT_PACKAGES_DIR}/share/anari/anariConfig.cmake"
  "  \${CMAKE_CURRENT_LIST_DIR}/../../../share/anari"
  "  \${CMAKE_CURRENT_LIST_DIR}/../../share/anari"
)

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
  "${CURRENT_PACKAGES_DIR}/share/anari/code_gen/__pycache__"
)

vcpkg_install_copyright(
  FILE_LIST "${SOURCE_PATH}/LICENSE"
)
