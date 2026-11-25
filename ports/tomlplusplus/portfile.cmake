vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF "v${VERSION}"
    SHA512 a06b9c28559e34baf75d58457ef7b65ef092aee2240374b5abfe9c30ee64f5801ec3eeb4ab72238f7850b3ad981c9843a9c79b3b921cf816a2404d1cc3e7ee44
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbuild_lib=true
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
