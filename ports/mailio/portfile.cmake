vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO karastojko/mailio
    REF "${VERSION}"
    SHA512 ecbc1e654f2aa4b8e6d61c825f1358bdcaf322389efdcb5bacfff90629a2489e6b3c97867ed9095a8acb77b7d834a68e31b4b68297f218cafa3081d1846fb980
    HEAD_REF master
    PATCHES
        fix-pkgconfig-paths.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMAILIO_BUILD_DOCUMENTATION=OFF
        -DMAILIO_BUILD_EXAMPLES=OFF
        -DMAILIO_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
     CONFIG_PATH lib/cmake/mailio
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
