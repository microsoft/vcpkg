vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF 713ed4876135dfaa9b744b567f7c300eae09800d # v.1.5.0
    SHA512 51b1e9521288c4cfbbf29aa9719b9da3ee0073e38af6fc275a5ec0a22b4bededf293b136aac0cf99a435b4411ccf0687556418fc25285f501a6f426f3a623c34
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/dev/so_5_extra"
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/so5extra)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/so5extra" RENAME copyright)

