vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baresip/re
    REF "v${VERSION}"
    SHA512 c37e49cca0d7ff591a3d178cbf58511d27e08be2c9b210353d9f65bb2cd76d135e0e023702140623630440ffdcc7b4c51ac29495bd85df4424627a5a69adba52
    HEAD_REF main
    PATCHES
        766.diff
        cmake.diff
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
