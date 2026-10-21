vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tomwillow/tomsolver
    REF "${VERSION}"
    SHA512 00e1b961b1e6730bf74209622a44f932b5221c15995c53bcea9de5b84ba7d75549c095658bcb5729d4a38bf60104b5c5a8fa97015f13977341fcdd62643f35c2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
