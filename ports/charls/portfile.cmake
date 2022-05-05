vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO team-charls/charls
    REF 662d4f2a0238357ccc4d89cd14b1fa67d2597ff1 #v2.3.4
    SHA512 f022d025ae1d5ff624982ceb61ee88c5a42ee958afcff39fbc3e698030092b6667c3a685b66b7fd16ab7c3d3af1d44b773f761e2eefd7f026432b80176b6894b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCHARLS_BUILD_TESTS=OFF
        -DCHARLS_BUILD_SAMPLES=OFF
        -DCHARLS_BUILD_FUZZ_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/charls)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
