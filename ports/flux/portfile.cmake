vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcbrindle/flux
    REF "v${VERSION}"
    SHA512 ac6f373d2b6b7f568528ba489aa0b1785ce9e25ba1c75ec23a3a7b517d54534491be0f808a09778e651791e61cc4bf407b8c18ff6aa53af4ae7cd9b518a8df43
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLUX_BUILD_EXAMPLES=OFF
        -DFLUX_BUILD_TESTS=OFF
)


vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/flux)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
