vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF "v.${VERSION}"
    SHA512 5744dbb3739d00fa9928718b734611c190ffe8a44ce2dd66f05333abe09dc0e59a4453a0ea4d0b714d81627e7f876493a8c87022bf10ea2011ce94f04b41b54f
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

