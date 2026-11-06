set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/ANARI-SDK
    REF "v${VERSION}"
    SHA512 c5827d637f51267454ccd905aa5349f99e7c8347b412bcbedbe4c552657812b544a7be88737d2d4cd3cfcc8f8a23550365d128a47536425e3f4a6442e11841ca
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
file(GLOB ANARI_CMAKE_CONFIG_FILE RELATIVE "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/lib/cmake/*/anariConfig.cmake")
cmake_path(GET ANARI_CMAKE_CONFIG_FILE PARENT_PATH ANARI_CMAKE_CONFIG_DIR)
vcpkg_cmake_config_fixup(
    CONFIG_PATH "${ANARI_CMAKE_CONFIG_DIR}"
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
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
)
