vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmaloney/libE57Format
    REF "v${VERSION}"
    SHA512 415c003720349dc3257dee9df67a5be46ffc0ec5e6c5e935eec8e0fc5ac44add1ab11c0f8ff326d19881bc28429eee6490d03bd26558e20b85bb8bcddeb41019
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
