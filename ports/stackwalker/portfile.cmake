vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JochenKalmbach/StackWalker
    REF "${VERSION}"
    SHA512 ce4004f114400ff66e25d7403c52ed4798a0e94d529335995df525f37d4238c750c8b1ee5801f71bd7128d39baa9af18e546a49da8587976720df6e9b372b851
    HEAD_REF master
    PATCHES
        fix-build.patch # https://github.com/JochenKalmbach/StackWalker/commit/97965daed94f1d859fff691e6ba28759db0f179f
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
