vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/mvfst
    REF "v${VERSION}"
    SHA512 1f2fa62be05fea05b2bbad1dd711a468a3552344c4908e7f53c761a893668ac7cef16aa93d042d4e7f9ba3978e605ab98ba43b8a49263b01519a7e585c8a3777
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mvfst)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
