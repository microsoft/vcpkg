vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cieslarmichal/faker-cxx
    REF "v${VERSION}"
    SHA512 95ceedfa71889c9c5299949d51fe54936c94dc12a5e46e90c6aae3124cbdd5de627725afc3407bb27401addf7338ba77b70c66b6fe750c8499c3b070558c467b
    HEAD_REF main
    # Remove when https://github.com/cieslarmichal/faker-cxx/issues/1126 is fixed in a release.
    PATCHES
        fix-version-metadata.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFAKER_BUILD_TESTING=OFF
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME faker-cxx
    CONFIG_PATH "lib/cmake"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSES.md"
        "${CMAKE_CURRENT_LIST_DIR}/oklog-ulid-LICENSE"
)
