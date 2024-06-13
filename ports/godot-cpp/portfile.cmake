
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "godotengine/godot-cpp"
    REF "godot-${VERSION}-stable"
    SHA512 "820e07ffb0545324f01598898bb342d7e143dcc8b83818824e7e1bc22937d3e8016b435f1ec085ebaae8b26e6f6dfb5500f120089316fc0f0c4153c340226941"
    HEAD_REF "master"
    PATCHES
        "packagable.patch"
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPython3_EXECUTABLE=${PYTHON3}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-${PORT}")
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
