vcpkg_download_distfile(
    patch_gui_private
    URLS https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System/commit/893af516b2a312751edc460f5a9117e319865485.diff
    FILENAME 893af516b2a312751edc460f5a9117e319865485.diff
    SHA512 7ab7f02546723225a9869e39b0525a8e3f9f2e6b6265c883a399249482522d883b062250972c66c78c611046eba48a323a9cfecac90400dc676302f68c3cc8ac
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF "${VERSION}"
    SHA512 c5a7ddeb18e86cbda32829d0fc1e8fa7f14fdc7057dff1d1fb416a29f394ca676bcc611c3d537ebf496929ea4090ca9c1b2c9d1273117022de863565cdc3a1a6
    HEAD_REF master
    PATCHES
      ${patch_gui_private}
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
