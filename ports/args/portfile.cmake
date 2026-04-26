vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF "${VERSION}"
    SHA512 acddaacfd458601250c687c582dc0657d7d2d41ce22f56d9d9431838c1e7a30fdf02bf65ff3b8708858cd8e7368d1885a56b03c7bfd5c854795e8207e5a4d5b3
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
