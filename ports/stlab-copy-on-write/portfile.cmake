vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/copy-on-write
    REF "v${VERSION}"
    SHA512 14fd31c27a45111050b5b4e7164ef1467cecc0c1b258172d954700a0e0b6ce69cb28b700d5ca145c37974e4fdffe1563e13ea627b6cce11599381d7aa6cd0f54
    HEAD_REF main
    PATCHES
        disable-tests.patch
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dstlab-copy-on-write_IS_TOP_LEVEL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stlab-copy-on-write)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
