vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmaloney/libE57Format
    REF "v${VERSION}"
    SHA512 e5cb692f1318bff33a9196e8dd879eee1dc34160e670bc7efb239d0c437d4c47c0eda468a92103005950e1a393d6b8bf0d07681bae84f9a628551783980205f5
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" E57_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DE57_BUILD_TEST=OFF
        -DE57_BUILD_SHARED=${E57_BUILD_SHARED}
        -DE57_RELEASE_LTO=OFF
        -DE57_USE_EXTERNAL_CRCPP=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=1
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME e57format CONFIG_PATH "lib/cmake/E57Format")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
