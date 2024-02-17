vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  libsdl-org/SDL_ttf
    REF "release-${VERSION}"
    SHA512 ea059fce879f8ddb3b36f8364d65ef922c389db67383d8a5c42c0ebf8a407d55adce42620b4d04caa0b297847362cc733a9d3d9acb843897a535c875fd0c471f
    HEAD_REF main
    PATCHES
        fix-pkgconfig.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        harfbuzz SDL2TTF_HARFBUZZ
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL2TTF_VENDORED=OFF
        -DSDL2TTF_SAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL2_ttf CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL2_ttf CONFIG_PATH lib/cmake/SDL2_ttf)
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/licenses")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
