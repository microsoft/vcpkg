vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xalan-c
    REF 4055bb0c58e3053b04fcd0c68fdcda8f84411213 #1.12
    SHA512 0d591f5a07dbc69050c7b696189c46a32e6dd7a80a302fd38dcc82f9454688729e361c4d5c3b0aacfc3acc7df78c0981ba54eb3ce82b1ca6566a30aa19648280
    PATCHES
        fix-win-deprecated-err.patch
        fix-missing-dll-error.patch
        fix-linux-no-bin.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_ICU=ON
)

vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES Xalan AUTO_CLEAN)

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME xalanc)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/XalanC PACKAGE_NAME xalanc)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
