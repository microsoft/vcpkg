vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO free-audio/clap
    REF "${VERSION}"
    SHA512 bb927a53d10ea7680f43a4139db6bcd293a051e9cab4293612cba29858ec18760d97de331da8eaa948844fd4ce38e895ee0b731654c42e3adbdc9000d1727884
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/clap"
)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
