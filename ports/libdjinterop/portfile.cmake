vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xsco/libdjinterop
    REF "${VERSION}"
    SHA512 c2784ffc6b0ddc9ad92a227621bb00cd1c88aa8f8abe82401774102f9be16dfbe9f0745523d517594faecba60b650a53613c7867afe57e6bcd8a2cc6288dd9ff
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
    )
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME djinterop CONFIG_PATH lib/cmake/DjInterop)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
