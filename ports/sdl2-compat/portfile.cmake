vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/sdl2-compat
    REF "release-${VERSION}"
    SHA512 fd3ea427d5ed7a4363b6e72d27d5d42daca09e26fd24a9e30c4ca427169b03a21d1f0ae366d2ce19b29e7d3a5ff0dd158321dadb1a362feb4436f0ea8a6b3add
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL2COMPAT_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        x11               CMAKE_REQUIRE_FIND_PACKAGE_X11
    INVERTED_FEATURES
        x11               CMAKE_DISABLE_FIND_PACKAGE_X11
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSDL2COMPAT_STATIC=${SDL2COMPAT_STATIC}
        -DSDL2COMPAT_TESTS=OFF
        -DSDL2COMPAT_INSTALL_CMAKEDIR=share/${PORT}
        # Specifying the revision skips the need to use git to determine a version
        -DSDL_REVISION=vcpkg
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_X11
        CMAKE_DISABLE_FIND_PACKAGE_X11
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/bin/sdl2-config"
    "${CURRENT_PACKAGES_DIR}/debug/bin/sdl2-config"
)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
