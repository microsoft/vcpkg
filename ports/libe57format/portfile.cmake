vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmaloney/libE57Format
    REF "v${VERSION}"
    SHA512 545e4beeeade562b8c7dda29e4879132ff59f5f45f1e1a2e4fbff266c5f1e9035e99d70070317559786bdc8c3a73de9813c7cb1e9823d5e109d14a43028e8432
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" E57_BUILD_SHARED)
string(COMPARE NOTEQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" E57_USING_STATIC_XERCES)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DE57_BUILD_TEST=OFF
        -DE57_BUILD_SHARED=${E57_BUILD_SHARED}
        -DUSING_STATIC_XERCES=${E57_USING_STATIC_XERCES}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME E57Format CONFIG_PATH "lib/cmake/E57Format")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/libe57format RENAME copyright)
