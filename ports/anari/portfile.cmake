vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/ANARI-SDK
  REF "v${VERSION}"
  SHA512 978522469621694022be1a5425306832344a4b64ff5cc8fbb9267a683889d4624edd8a59b6488ecc6dcc8a851c74b92b6918470ad69c4d9363596f621688973d
  HEAD_REF next_release
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_EXAMPLES=OFF
    -DBUILD_VIEWER=OFF
    -DBUILD_CTS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_HDANARI=OFF
    -DBUILD_HELIDE_DEVICE=OFF
    -DBUILD_REMOTE_DEVICE=OFF
    -DBUILD_TESTING=OFF
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
      "${CURRENT_PACKAGES_DIR}/bin"
      "${CURRENT_PACKAGES_DIR}/debug/bin"
  )
endif()

vcpkg_install_copyright(
  FILE_LIST "${SOURCE_PATH}/LICENSE"
)
