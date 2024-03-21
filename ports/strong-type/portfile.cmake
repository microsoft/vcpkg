vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "rollbear/strong_type"
    REF "v${VERSION}"
    SHA512 "8accb839e52e87d871ef5321e73e93744c174ef01417c5fc2ef2ef692639db5b2cd2286a11aaa3b320d8e485823bd05980267711fa942d60ca496e1ec0a7dc39"
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "strong_type" CONFIG_PATH "lib/cmake/strong_type")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
