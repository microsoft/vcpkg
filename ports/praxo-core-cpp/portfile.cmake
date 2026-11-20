vcpkg_from_git(
    URL https://github.com/axisvela/praxo-core.git
    REF da4cae049176c5f9d4d6912cdef3f69e1a10db41
    OUT_SOURCE_PATH SOURCE_PATH
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/language/cpp"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME praxo-cpp
    CONFIG_PATH lib/cmake/praxo-cpp
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
