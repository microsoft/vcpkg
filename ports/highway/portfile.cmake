vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/highway
    REF 1.0.2
    SHA512 d4c57b297f073dd83535c60151bbc7e7960262990d89bc78882adeb457ed7cf6d54ec852ecb1847c7760de3992267b66538971d20a2c2935828d95d99ddb3a3f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHWY_ENABLE_EXAMPLES=OFF
        -DHWY_ENABLE_TESTS=OFF
)

vcpkg_cmake_install()

# remove test-related pkg-config files that break vcpkg_fixup_pkgconfig
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libhwy-test.pc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libhwy-test.pc")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
