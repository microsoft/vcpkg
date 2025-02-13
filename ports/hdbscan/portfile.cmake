vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ooraloo/hdbscan-cpp-vcpkg
    REF "v${VERSION}"
    SHA512 3aa8a51fb625728d200d6c3384b1984900ccd7a0fac8245d5843375bb7840799509f226d5a0b1773637a336ead21d1e221fe0059fa9eda37b9464a35c4b44699
    HEAD_REF "master"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.md)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")