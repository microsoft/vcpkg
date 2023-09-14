vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF "${VERSION}"
    SHA512 d7b1501cd8d15aead7eca38172f3335d5a5f3165f948658df09016b773a870f024d16bf472ed7a65cb178408177a6af9db647892942818e53d044f67648e3435
    HEAD_REF master
    PATCHES
        qt.patch
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
vcpkg_cmake_config_fixup(PACKAGE_NAME "qt6advanceddocking" CONFIG_PATH "lib/cmake/qt6advanceddocking")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/qt6advanceddocking/qt6advanceddockingConfig.cmake"
"include(CMakeFindDependencyMacro)"
[[include(CMakeFindDependencyMacro)
find_dependency(Qt6 COMPONENTS Core Gui Widgets)]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/license")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/license")

file(INSTALL "${SOURCE_PATH}/gnu-lgpl-v2.1.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
