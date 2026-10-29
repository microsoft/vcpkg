vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seleznevae/libfort
    REF "v${VERSION}"
    SHA512 2e71b6c1308c5ced48621df1fb391a1fcf6a1eb6a17c31fc1911cb4483bea267c3531da07c3a319a6371937aae8c9ad10ac6c9f972029bbc579831cfc0f52326
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFORT_ENABLE_TESTING=OFF
        -DFORT_ENABLE_ASTYLE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libfort)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
