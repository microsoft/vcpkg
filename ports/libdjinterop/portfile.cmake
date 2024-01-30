vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xsco/libdjinterop
    REF "${VERSION}"
    SHA512 2f75a57326cc958bce6634aba407707313cec646d1713c80d9286d9d2448a68dd304eacd02b38c237a6bb869f07b9b3d3b1cc7fcb7c3a9cdf6ba7515166be6cf
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
