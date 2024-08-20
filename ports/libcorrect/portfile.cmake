vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO quiet/libcorrect
    REF f5a28c74fba7a99736fe49d3a5243eca29517ae9
    SHA512 1367834c2a081e007b3eeeacb5bbe912617cce97cbd19d43193078f352fef103a54f030ef61a2def4ab7517476cf6be5d6a1736e43ae84913fe84a56340b69ce
    HEAD_REF master
    PATCHES fix-ninja.patch
)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
