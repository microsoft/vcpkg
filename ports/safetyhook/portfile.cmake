vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cursey/safetyhook
    REF "v${VERSION}"
    SHA512 6eca97f480ef86680646feb0581e587d856475da211ddcbcf1a837dda7ef289dee989128a714779924f48b192ee1e776f529c9c43e81d18ce776c5260090753a
    HEAD_REF main
)

vcpkg_find_acquire_program(GIT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DGIT_EXECUTABLE=${GIT}"
        "-DSAFETYHOOK_FETCH_ZYDIS=OFF"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/safetyhook)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
