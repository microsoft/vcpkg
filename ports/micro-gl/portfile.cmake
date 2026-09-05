vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO micro-gl/micro-gl
    REF b3c293f461763f68a664efbe1b9c2de8fb19e073
    SHA512 8b56b1d9a429ad0e429e0cfd0ca82615a0cb9634f5c56a112c6186bd1fb21853bc6f903292d9924bdfc869602b6e0610d0cfb9c4f2d0369c7606f581074b03d3
    HEAD_REF master
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "add_subdirectory(examples)" "")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME microgl CONFIG_PATH "share/microgl/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MD")
