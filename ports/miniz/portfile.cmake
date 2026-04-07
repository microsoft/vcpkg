vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO richgel999/miniz
    REF "${VERSION}"
    SHA512 b2116d01161e6ba978541da3b1040338158a2da0d4559ae2817c1bd19a56472476b6984d438e7b8451aa0142d0405858342d719a76bd3bd6fd2df3ff6edc0700
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_TESTS=OFF
        -DINSTALL_PROJECT=ON
        -DCMAKE_POLICY_DEFAULT_CMP0057=NEW
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/miniz)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
