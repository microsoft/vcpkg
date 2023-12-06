vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF "${VERSION}"
    SHA512 5b433845ce4a8590e72c045a40ab62602b798dad46eb192210815c11507700026073a6a8a528aaf567786931d587ef58f90b459a747a91856ce1cc4f2835b0e9
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGS_BUILD_UNITTESTS=OFF
        -DARGS_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
