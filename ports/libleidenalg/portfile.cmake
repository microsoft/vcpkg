vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vtraag/libleidenalg
    REF "${VERSION}"
    SHA512 f9e7b6157b2a871c4e9979245b91992b8edcd8bf2c98b5138bfa5786e227b41a9606ac18b4e4b2148e357bfabdf7b48cdf9a597e957c5fd391f2eb2f5e19f530
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
