vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO team-charls/charls
    REF 0bafe4ecdc591f633303ad0d32f3f6c38d099802 #v2.2.0
    SHA512 56acb0085a4f653660166c11982934d7f8c8836db63339aaca700aabade2bf7cff8cba77f9f04a68bbc119b5b15800bf01ffb10628703fb2188f6e654d0e5f22
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCHARLS_BUILD_TESTS=OFF
        -DCHARLS_BUILD_SAMPLES=OFF
        -DCHARLS_BUILD_FUZZ_TEST=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/charls)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
