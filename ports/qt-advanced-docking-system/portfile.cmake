vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF "${VERSION}"
    SHA512 ae9345e0876a80e2f2dfa393d12176215cdcf17ed1985d2e46527d12a3abf4ea2b7796217871b562aaab9c7c876bef226de661d5e9cbdc862c8f49d57e9e8173
    HEAD_REF master
    PATCHES
        set_cmake_module_path.patch
        fix_windows_version_resources_generation.patch
)

if(VCPKG_CROSSCOMPILING)
    list(APPEND _qarg_OPTIONS "-DQT_HOST_PATH=${CURRENT_HOST_INSTALLED_DIR}")
    list(APPEND _qarg_OPTIONS "-DQT_HOST_PATH_CMAKE_DIR:PATH=${CURRENT_HOST_INSTALLED_DIR}/share")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${_qarg_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DADS_VERSION=${VERSION}
        -DQT_VERSION_MAJOR=6
        -DBUILD_STATIC=${BUILD_STATIC}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME "qtadvanceddocking-qt6" CONFIG_PATH "lib/cmake/qtadvanceddocking-qt6")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/qtadvanceddocking-qt6/qtadvanceddocking-qt6Config.cmake"
"include(CMakeFindDependencyMacro)"
[[include(CMakeFindDependencyMacro)
find_dependency(Qt6 COMPONENTS Core Gui Widgets)]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/license")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/license")

file(INSTALL "${SOURCE_PATH}/gnu-lgpl-v2.1.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
