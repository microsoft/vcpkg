vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDDockWidgets
    REF "v${VERSION}" 
    SHA512 7b88f354e2aca4ac4c0f59874b6a7d6baaf77f5b54dd57b981ec7831e40acc0e2f6d3c6300af3d93c594bf34c7072c6a8a19a50c65039ccae22a9e47b90499d8
    HEAD_REF master
    PATCHES
        dependencies.diff
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/src/3rdparty"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KD_STATIC)

if(VCPKG_CROSSCOMPILING)
    list(APPEND _qarg_OPTIONS
        "-DQT_HOST_PATH=${CURRENT_HOST_INSTALLED_DIR}"
        "-DQT_HOST_PATH_CMAKE_DIR:PATH=${CURRENT_HOST_INSTALLED_DIR}/share"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${_qarg_OPTIONS}
        -DKDDockWidgets_QT6=ON
        -DKDDockWidgets_FRONTENDS=qtwidgets
        -DKDDockWidgets_STATIC=${KD_STATIC}
        -DKDDockWidgets_PYTHON_BINDINGS=OFF
        -DKDDockWidgets_TESTS=OFF
        -DKDDockWidgets_EXAMPLES=OFF
        # https://github.com/KDAB/KDDockWidgets/blob/v2.1.0/CMakeLists.txt#L301
        -DCMAKE_DISABLE_FIND_PACKAGE_spdlog=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_fmt=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_nlohmann_json=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/KDDockWidgets-qt6" PACKAGE_NAME kddockwidgets-qt6)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.txt"
    "${SOURCE_PATH}/LICENSES/GPL-2.0-only.txt"
    "${SOURCE_PATH}/LICENSES/GPL-3.0-only.txt"
)
