vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO index1207/netcpp
    REF "v${VERSION}"
    SHA512 18b322ec599dc2ece84d31bf723e8d1c8bf107e93a39a58dee27e7e59de7e0387c72a638d5a59eda43706f39a054b3325e3f40f093edf8d673061c526d30b06b
    HEAD_REF release
    PATCHES
        pkgconfig.patch
)

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(PKGCONFIG)
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINCLUDE_TEST=OFF
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)
vcpkg_fixup_pkgconfig()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/netcpp PACKAGE_NAME netcpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
