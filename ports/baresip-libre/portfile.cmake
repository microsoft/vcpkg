if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baresip/re
    REF "v${VERSION}"
    SHA512 7c03502aae0424bb05e03320c2497de0ec534d872334fe16ec0a688efbc1cc493ad1774e9802e0dc58bb396b4b8a065f3e338deeff4dd1ddd87cb76793e82306
    HEAD_REF main
    PATCHES
        fix-static-library-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBRE_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBRE_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBRE_BUILD_SHARED=${LIBRE_BUILD_SHARED}
        -DLIBRE_BUILD_STATIC=${LIBRE_BUILD_STATIC}
        -DCMAKE_DISABLE_FIND_PACKAGE_Backtrace=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME libre CONFIG_PATH lib/cmake/libre)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
