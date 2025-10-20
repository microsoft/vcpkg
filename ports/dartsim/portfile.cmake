# DLL support is broken upstream (https://github.com/dartsim/dart/issues/1005#issuecomment-375406260)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dartsim/dart
    REF v${VERSION}
    SHA512 3c621245c5dc1bf26932c33c940e2b09aaebd1a15f3620616c60296f18a67e1044728543b4f640f92caf8f98295e350679b70eb11aecadea9e4a28aaf370ea75
    HEAD_REF main
    PATCHES
        dependencies.diff
        devendor-lodepng.diff
        disable_unit_tests_examples_and_tutorials.patch
        pkgconfig.diff
        add-cassert.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/dart/external/imgui")

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        collision-bullet    CMAKE_REQUIRE_FIND_PACKAGE_BULLET
        collision-ode       CMAKE_REQUIRE_FIND_PACKAGE_ODE
        gui                 CMAKE_REQUIRE_FIND_PACKAGE_GLUT
        gui-osg             DART_BUILD_GUI_OSG
        spdlog              CMAKE_REQUIRE_FIND_PACKAGE_spdlog
        utils               CMAKE_REQUIRE_FIND_PACKAGE_tinyxml2
        utils-urdf          CMAKE_REQUIRE_FIND_PACKAGE_urdfdom
    INVERTED_FEATURES
        collision-bullet    CMAKE_DISABLE_FIND_PACKAGE_BULLET
        collision-ode       DART_SKIP_ODE
        gui                 DART_SKIP_GLUT
        gui                 DART_SKIP_OPENGL
        spdlog              DART_SKIP_spdlog
        utils               DART_SKIP_TINYXML2
        utils-urdf          CMAKE_DISABLE_FIND_PACKAGE_urdfdom
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DDART_VERBOSE=ON
        -DDART_TREAT_WARNINGS_AS_ERRORS=OFF
        -DDART_MSVC_DEFAULT_OPTIONS=ON
        -DDART_USE_SYSTEM_IMGUI=ON
        -DDART_BUILD_DARTPY=OFF
        -DDART_SKIP_DOXYGEN=ON
        -DDART_SKIP_IPOPT=ON
        -DDART_SKIP_NLOPT=ON
        -DDART_SKIP_pagmo=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
    OPTIONS_DEBUG
        -DDART_PKG_DEBUG_POSTFIX=d
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_urdfdom
        CMAKE_REQUIRE_FIND_PACKAGE_GLUT
        CMAKE_REQUIRE_FIND_PACKAGE_urdfdom
        DART_MSVC_DEFAULT_OPTIONS
        DART_SKIP_GLUT
        DART_SKIP_OPENGL
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/dart/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# only used for tests and examples (we removed the examples in share/doc above):
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_ROOT_PATH \"${SOURCE_PATH}/\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_DATA_PATH \"${SOURCE_PATH}/data/\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_DATA_LOCAL_PATH \"${SOURCE_PATH}/data/\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_DATA_GLOBAL_PATH                                                  \\\n  \"${CURRENT_PACKAGES_DIR}/share/doc/dart/data/\"" "")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(COPY_FILE "${SOURCE_PATH}/dart/external/convhull_3d/convhull_3d.h" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/convhull_3d LICENSE")
vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/convhull_3d LICENSE" [[[*]/.*]] [[*/]] REGEX)
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/convhull_3d LICENSE"
)
