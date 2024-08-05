
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "godotengine/godot-cpp"
    REF "godot-${VERSION}-stable"
    SHA512 "aa7fbdc398eda9abbfbbe4d0cfed2ce4651cc5ca4d8d246d739dc3814e766011ff8bb221ad4033830bfb7926adbb69f6f26dc7356c9a7cb3f1e8d39f4db053fc"
    HEAD_REF "master"
    PATCHES
        "hotreloadable.patch"
        "packagable.patch"
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "hotreload"    "GODOT_ENABLE_HOT_RELOAD"
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
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
