vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sfml/imgui-sfml
    REF "v${VERSION}"
    SHA512 be02207533b532f10038bb83eb49311e57774dbddd1bac2ebb1789cbdef2abbfa24cee59b8b5889302feba72af1e98a4a1c7ac063e7d815ce1f2ef9bd40cf552
    HEAD_REF master
    PATCHES
        0001-fix_find_package.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ImGui-SFML)
file(READ "${CURRENT_PACKAGES_DIR}/share/imgui-sfml/ImGui-SFMLConfig.cmake" cmake_config)
string(PREPEND cmake_config [[
include(CMakeFindDependencyMacro)
find_dependency(imgui CONFIG)
find_dependency(SFML COMPONENTS Graphics Window System)
]])
file(WRITE "${CURRENT_PACKAGES_DIR}/share/imgui-sfml/ImGui-SFMLConfig.cmake" "${cmake_config}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
