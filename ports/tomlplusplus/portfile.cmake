vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF "v${VERSION}"
    SHA512 c227fc8147c9459b29ad24002aaf6ab2c42fac22ea04c1c52b283a0172581ccd4527b33c1931e0ef0d1db6b6a53f9e9882c6d4231c7f3494cf070d0220741aa5
    HEAD_REF master
    PATCHES
        fix-android-fileapi.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbuild_tests=false
        -Dbuild_examples=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tomlplusplus)
# Fixup link lib name and multi-config
find_library(lib NAMES tomlplusplus PATHS "${CURRENT_PACKAGES_DIR}/lib" NO_DEFAULT_PATH REQUIRED)
cmake_path(GET lib FILENAME name)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/tomlplusplus/tomlplusplusConfig.cmake"
    [[(IMPORTED_LOCATION "..PACKAGE_PREFIX_DIR./lib/)[^"]*"]]
    " \\1${name}\""
    REGEX
)
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/tomlplusplus/tomlplusplusConfig.cmake"
        [[IMPORTED_LOCATION ("..PACKAGE_PREFIX_DIR.)(/lib/[^"]*")]]
        [[IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
          IMPORTED_LOCATION_DEBUG \1/debug\2
          IMPORTED_LOCATION_RELEASE \1\2]]
        REGEX
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
