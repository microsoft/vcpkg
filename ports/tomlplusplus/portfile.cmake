vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF v3.0.1
    SHA512 bfb05d16715d1e8b54177e905c0a83470e7472c9c474874d70528558bbf0b0ba0daae67e1e44d99c45de3f87918bca57e889caba2e3da5e351045aee7e6a144b
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
cmake_path(NATIVE_PATH SOURCE_PATH native_source_path)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/tomlplusplus/tomlplusplusConfig.cmake" "${native_source_path}" "")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
