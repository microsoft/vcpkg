vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO P-H-C/phc-winner-argon2
    REF 20190702
    SHA512 0a4cb89e8e63399f7df069e2862ccd05308b7652bf4ab74372842f66bcc60776399e0eaf979a7b7e31436b5e6913fe5b0a6949549d8c82ebd06e0629b106e85f
    HEAD_REF master
    PATCHES
        visibility.patch
        thread-header.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION  "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/unofficial-libargon2 PACKAGE_NAME unofficial-libargon2)

vcpkg_copy_tools(TOOL_NAMES argon2_tool AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(RENAME "${CURRENT_PACKAGES_DIR}/tools/${PORT}/argon2_tool${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/argon2${VCPKG_HOST_EXECUTABLE_SUFFIX}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-libargon2-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-libargon2/unofficial-libargon2-config.cmake" @ONLY)
