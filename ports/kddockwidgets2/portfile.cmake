if(EXISTS "${CURRENT_INSTALLED_DIR}/share/kddockwidgets/copyright")
  message(FATAL_ERROR "'${PORT}' conflicts with 'kddockwidgets'. Please remove kddockwidgets:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDDockWidgets
    REF 73ebd9d50643a0176f7912918e0989562cccc0f4
    SHA512 43d75d0701d24210af4e077f594654b0d87f2b777f89f9eae0420ca8b455e3d6b44ac2953f65bc2003a460c768938fefa409e5e2bb753d60298b9324eb33bb0f
    HEAD_REF 2.0
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KD_STATIC)

if(VCPKG_CROSSCOMPILING)
    list(APPEND _qarg_OPTIONS -DQT_HOST_PATH=${CURRENT_HOST_INSTALLED_DIR})
    list(APPEND _qarg_OPTIONS -DQT_HOST_PATH_CMAKE_DIR:PATH=${CURRENT_HOST_INSTALLED_DIR}/share)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${_qarg_OPTIONS}
        -DKDDockWidgets_QT6=ON
        -DKDDockWidgets_STATIC=${KD_STATIC}
        -DKDDockWidgets_QTQUICK=ON
        -DKDDockWidgets_PYTHON_BINDINGS=OFF
        -DKDDockWidgets_EXAMPLES=OFF
    MAYBE_UNUSED_VARIABLES
        KDDockWidgets_QTQUICK
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/KDDockWidgets-qt6" PACKAGE_NAME "KDDockWidgets-qt6")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
