vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JochenKalmbach/StackWalker
    REF "${VERSION}"
    SHA512 6fe8c5eb6e2d94630d43644a13cf62f1725a9f39115bda2d859461ad0cc6acf27e8a246247bd9b49940fb4ec372559f6d11467e77215d3638f910f2574ac449a
    HEAD_REF master
    PATCHES
        fix-exports.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DStackWalker_DISABLE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
