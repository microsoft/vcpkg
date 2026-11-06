vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Game-Asset-Conditioning-Library
    REF "${VERSION}"
    SHA512 d856e666a71dd39818d089c6db94cf5e52450d51446065de64b85d01b5149d000db23845114f8372d5e9a406ed20933c1211f8eaff5017831e5488739237afdb
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGACL_INSTALL=ON
        -DGACL_BUILD_TOOLS=ON
        -DGACL_ENABLE_CLER=OFF
        -DVCPKG_MANIFEST_MODE=OFF
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES gacl AUTO_CLEAN)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME GACL
    CONFIG_PATH lib/cmake/GACL
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
