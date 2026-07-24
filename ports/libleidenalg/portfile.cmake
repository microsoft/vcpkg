vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vtraag/libleidenalg
    REF "${VERSION}"
    SHA512 1d93d3cb5f91944471e4a9ff6736b581195412a132574dfe56be3b99b7609f2d8cdb7e36d1dce8b6396e79bebc4932f6c96f0159bd97a7b6dbc5f64d7901f4fd
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
