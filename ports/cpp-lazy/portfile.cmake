vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kaaserne/cpp-lazy
    REF "v${VERSION}"
    SHA512 e93a63e434be1fd25d842c0930159d9f31a565b905eb5d93d9066f32a0140034314c4228842bc534b3573b7ed8778fd01c0f7d4c35ca53ea1b73f86007e0873a
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPP_LAZY_INSTALL=ON
        -DCPP_LAZY_USE_INSTALLED_FMT=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpp-lazy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
