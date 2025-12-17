vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pipacs/o2
    REF "${VERSION}"
    SHA512 ef51f5bd145a3800b6beb057d418d34470e109bc1c62adf38a64fb849d95f64989898b09787ee12361a6b2a6fb18dd0eaf8b1fe683430a0b5101495846a86d96
    HEAD_REF master
    PATCHES
        fix_cmake_minimum_version.patch
        add_qt6_support.patch
        fix_cmake_project_version.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQT_DEFAULT_MAJOR_VERSION=6
        -Do2_WITH_KEYCHAIN=OFF
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
