set(VERSION 2.20.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  libsdl-org/SDL_ttf
    REF f5e4828ffc9d3a84f00011fede4446aecb4a685f #v2.20.0
    SHA512 c0d2d6107e5427d9c1353e14cb4b0c3957d28391cfc772f1f972fe3aa8ba9e9dfdfcb64acd317a7836d46b3a50da9597b19a832f0baf5198654acb7b31ab1e6b
    HEAD_REF main
    PATCHES
        fix-find_dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL2TTF_SAMPLES=OFF
        -DSDL2TTF_HARFBUZZ=ON
)

vcpkg_cmake_install()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME SDL2_ttf)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SDL2_ttf PACKAGE_NAME SDL2_ttf)
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/licenses")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
