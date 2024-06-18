vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO micro-gl/micro-gl
    REF 1c1dafeccb1b92467d3fd82de00e022a318c8ce8
    SHA512 0
    HEAD_REF master
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "add_subdirectory(examples)" "")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME microgl CONFIG_PATH "share/microgl/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MD")
