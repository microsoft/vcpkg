set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
set(QT_CMAKE_DIR "${CURRENT_INSTALLED_DIR}/share/Qt6")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

# qt_install_submodule() from qtbase/cmake/qt_install_submodule
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF "${VERSION}"
    SHA512 fabb5329e93288993fa2d662fd1a7b678f61bdc9c12c9370de4879f82971471615c50c9a2313fe8d07647efc36bc8c4863333cd7ec573e52475aad48191718c7
    HEAD_REF master
    PATCHES modules-json.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
qt_cmake_configure(
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DADS_VERSION=${VERSION}
        -DQT_VERSION_MAJOR=6
        -DBUILD_STATIC=${BUILD_STATIC}
        -DQT_CMAKE_DIR=${QT_CMAKE_DIR}
    OPTIONS_MAYBE_UNUSED
        INSTALL_MKSPECSDIR
        QT_BUILD_BENCHMARKS
        QT_BUILD_EXAMPLES
        QT_BUILD_TESTS
        QT_MKSPECS_DIR
        QT_USE_DEFAULT_CMAKE_OPTIMIZATION_FLAGS
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME "qt6advanceddocking"
                         CONFIG_PATH "lib/cmake/qt6advanceddocking")
qt_fixup_and_cleanup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
