vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlink-systems/zlink
    REF core/v0.17.5
    SHA512 f733101cd4ac38500f7becf8791dc658a95e2399ef9d692bbe72aca3f06b6268d04fa7c064d30efbf65babf26d45564d1721fbd85969f30b66c33860c3b26579
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
        -DENABLE_LTO=OFF
        -DBUILD_TESTS=OFF
        -DZLINK_BUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DZLINK_CMAKECONFIG_INSTALL_DIR=lib/cmake/zlink
        -DWITH_DOC=OFF
        -DENABLE_CPACK=OFF
        -DWITH_TLS=ON
        -DWITH_LIBBSD=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()
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
