vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/highway
    REF 0.14.2
    SHA512 fc1a35463c95c45b646c53f91a9996112726de1d588dcd4d25a7d366840f704ad9a4c0bb6e0a001e929409f04aad6922cbffcf93774a0c360aff875956c7cc8d
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
