vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flatironinstitute/poet
    REF "v${VERSION}"
    SHA512 652af56a9e5a6eeea0154c75324c7f4d209f0e33c3d0eea9a718a5c3066142ae94c78205a13e3d849dad3ec8b19acfd7168135ef7b94c1770a23825720dc1931
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPOET_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME poet CONFIG_PATH lib/cmake/poet)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
