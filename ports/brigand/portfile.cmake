vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edouarda/brigand
    REF 1.3.0
    SHA512 538d288d84265cc9a4563f1e84d55a174db461ffd1e4f510bfdaef04af9fbf8e7ca79817f9118378bf7d58d578699aae3072bbffa3fd727b2d93ee783337aea6
    HEAD_REF master
    PATCHES
        remove-tests.patch
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
