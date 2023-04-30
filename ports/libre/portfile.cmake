
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baresip/re
    REF "v${VERSION}"
    SHA512 139243a2d999c5c58ad34ddc7693b93f90b981f807e85607532721a2014d963c0c5d810bee4626d39abcb968f40b5415b1675450f162d1a4c26417f02b7d9b34
    HEAD_REF main
    PATCHES
        776.diff
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Backtrace=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
)

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)

vcpkg_cmake_config_fixup(PACKAGE_NAME libre CONFIG_PATH lib/cmake/re)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
