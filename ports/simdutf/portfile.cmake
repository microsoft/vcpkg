vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdutf/simdutf
    REF v1.0.0
    SHA512 3ab09aa61cb9765bf1a77de59c5b823ee58ae5e4badfd5dd70e511fd4f378f8d3917a5b577e7f275720b975740344968132ce0b3f628452bde67f2ab6cc82337
    HEAD_REF master
    PATCHES
        disable-tests-and-benchmarks.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE-APACHE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
