vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vtraag/libleidenalg
    REF "${VERSION}"
    SHA512 a3077592b68cb6fd9bc24127898a64576982b608ff3c123e8b1c7ea1b8da2dfb302123fba64cbf93c16b9310ab42199ddc8de5efa5b6606dd49ee47f074f7f2f
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
