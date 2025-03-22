vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ada-url/idna
    REF "${VERSION}"
    SHA512 d0176445c0f98f6adc399c4a853248bd4b34cae9d151baf85ee60d285ec0fab59adeb4b3997fca0e9554bc6781bb7b6ac9ce74e8e3f1f04e863ea15c6b61845e
    HEAD_REF main
    PATCHES
        install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DADA_IDNA_BENCHMARKS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-ada-idna)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    COMMENT "ada-idna is dual licensed under Apache-2.0 and MIT"
    FILE_LIST
       "${SOURCE_PATH}/LICENSE-APACHE"
       "${SOURCE_PATH}/LICENSE-MIT"
)
