vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO acoustid/chromaprint
    REF "v${VERSION}"
    SHA512 ea16e4d2b879c15b1d9b9ec93878da8b893f1834c70942663e1d2d106c2e0a661094fe2dd3bae7a6c2a1f9d5d8fab5e0b0ba493561090cf57b2228606fad1e66
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
