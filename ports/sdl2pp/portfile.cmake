vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libSDL2pp/libSDL2pp
    REF "${VERSION}"
    SHA512 655412c93df5e6207064a07328785add4e7700a656295f03f0f2df4898ce62bd259340de28bf2a79db4fce765d2000ce6a43312dbe524f2b2b909a2dbf324859
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sdl2-image SDL2PP_WITH_IMAGE
        sdl2-mixer SDL2PP_WITH_MIXER
        sdl2-ttf   SDL2PP_WITH_TTF
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL2PP_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL2PP_WITH_EXAMPLES=OFF
        -DSDL2PP_WITH_TESTS=OFF
        -DSDL2PP_STATIC=${SDL2PP_STATIC}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.txt")
