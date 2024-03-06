vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axiomatic-systems/Bento4
    REF "v${VERSION}"
    SHA512 ad92c561a16a830ac63b0fbff98bd14f732dd2e38416de937191b14c750e632c793e5256b92361d3ff8867f9fd1cf727756ba78cd0122af1b79d62532d2ca427
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_APPS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bento4)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Documents/LICENSE.txt")
