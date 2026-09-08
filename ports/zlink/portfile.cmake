vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlink-systems/zlink
    REF core/v0.17.3
    SHA512 cdf4d4c4ecf1c15ea3856d4175b7bec6420c0feb5d2e82b4bf63a597bf187fba6aa4a0f09cad4745d387bd20f48a944b4a8bccaffa2cb6913eb50492e9a8f38c
    HEAD_REF main
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(ZLINK_BUILD_SHARED ON)
    set(ZLINK_BUILD_STATIC OFF)
else()
    set(ZLINK_BUILD_SHARED OFF)
    set(ZLINK_BUILD_STATIC ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/core"
    OPTIONS
        -DBUILD_SHARED=${ZLINK_BUILD_SHARED}
        -DBUILD_STATIC=${ZLINK_BUILD_STATIC}
        -DBUILD_TESTS=OFF
        -DZLINK_BUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DWITH_DOC=OFF
        -DENABLE_CPACK=OFF
        -DWITH_TLS=ON
        -DWITH_LIBBSD=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME zlink CONFIG_PATH lib/cmake/zlink)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(EXISTS "${SOURCE_PATH}/LICENSE")
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
elseif(EXISTS "${SOURCE_PATH}/COPYING")
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
else()
    message(FATAL_ERROR "No license file found in source tree")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
