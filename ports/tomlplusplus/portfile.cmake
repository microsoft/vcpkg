vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF v3.1.0
    SHA512 b5223fa978b606f6b14fa74495884ccd491fa6017ef44b2ac9a384fa1df7100745145163e2a139255927fb51e5ecd779ee2643c19579eab6e4533b15e75c9be9
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgenerate_cmake_config=true
        -Dbuild_tests=false
        -Dbuild_examples=false
)

vcpkg_install_meson()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/tomlplusplus)
cmake_path(NATIVE_PATH SOURCE_PATH native_source_path)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/tomlplusplus/tomlplusplusConfig.cmake" "${native_source_path}" "")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
