if("qtwidgets" IN_LIST FEATURES)
    list(APPEND FRONTEND_LIST "qtwidgets")
endif()

if("qtquick" IN_LIST FEATURES)
    list(APPEND FRONTEND_LIST "qtquick")
endif()

if(FRONTEND_LIST)
    list(JOIN FRONTEND_LIST ";" FRONTENDS)
else()
    message(FATAL_ERROR "No front-ends selected for ${PORT}, cannot build package")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDDockWidgets
    REF "v${VERSION}" 
    SHA512 1e220c5cf608c5bb9242b530eb1e45a15dae462b126c12d253483a1213e72374baa75943d8734c5dc79e34b03b480d1a87cd59cb945996abc0ab20b5d649a5cb
    HEAD_REF master
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
        -DKDDockWidgets_FRONTENDS=${FRONTENDS}
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
