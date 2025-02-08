vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/air-ctl
    REF "v${VERSION}"
    SHA512 88a20b0d833770820a8ef56725441cd4258b222ed12bb731a695c17a29c76709ed185f3a8e038d7f7437295847ff9ba77a65c5165ad7d70645c044a24365bfe9
    HEAD_REF master
    PATCHES
        fix-resize-error.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DCTL_CACHE_LINE_SIZE=0"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
