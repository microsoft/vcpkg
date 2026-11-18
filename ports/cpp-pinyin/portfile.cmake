vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/cpp-pinyin
    REF  "v${VERSION}"
    SHA512 e406b11601455e761eaf060ef064fba6310de33224e0f13751bd8a2557e0693680a9cfc221251bba9cfadd1e8fa02e87c0e733790833956e8217ae183deda5ee
    HEAD_REF main
    PATCHES
        fix-mac-static-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/cpp-pinyin2" PACKAGE_NAME cpp-pinyin2)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
