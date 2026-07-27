vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wirestead/wirestead
    REF v${VERSION}
    SHA512 28bb7a481a94d2e4ba1881d2b0bd2947a786167ba45af3265b31556596c8a205e178f444a8e70c2e3c80ae0526270b68d79d066e641ca24747c394fc10c43186
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" WIRESTEAD_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" WIRESTEAD_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWIRESTEAD_BUILD_SHARED=${WIRESTEAD_BUILD_SHARED}
        -DWIRESTEAD_BUILD_STATIC=${WIRESTEAD_BUILD_STATIC}
        -DWIRESTEAD_BUILD_TESTS=OFF
        -DWIRESTEAD_BUILD_DOCS=OFF
        -DWIRESTEAD_ENABLE_INSTALL=ON
        -DWIRESTEAD_ENABLE_PKGCONFIG=ON
        -DWIRESTEAD_ENABLE_EXPORT_HEADER=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME wirestead
    CONFIG_PATH "lib/cmake/wirestead"
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME unilink
    CONFIG_PATH "lib/cmake/unilink"
)

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    foreach(_pc_file IN ITEMS
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wirestead.pc"
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wirestead.pc"
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unilink.pc"
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/unilink.pc")
        if(EXISTS "${_pc_file}")
            file(READ "${_pc_file}" _wirestead_pc_contents)
            string(REGEX REPLACE "([ \t]+)-lboost_system" "\\1" _wirestead_pc_contents "${_wirestead_pc_contents}")
            string(REPLACE "-lboost_system" "" _wirestead_pc_contents "${_wirestead_pc_contents}")
            file(WRITE "${_pc_file}" "${_wirestead_pc_contents}")
        endif()
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
