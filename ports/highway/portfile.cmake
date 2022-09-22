vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/highway
    REF 1.0.1
    SHA512 35b6287579b6248966b0d36fda1522fd6338523934b079e94e857f9de08354f20b99739c99d53249a3a6c583519da0e0ac5e06dfbe6e3a89262f627c75b59dd8
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

# remove test-related pkg-config files that break vcpkg_fixup_pkgconfig
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libhwy-test.pc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libhwy-test.pc")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
