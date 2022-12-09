vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF 1.23.1
    SHA512 d01e168b02c0540e193f65ad630180b26ac1690b9386aac039149493f436938fed4a0499ac70235f53d2675df595b7223401804b3bd2d8660917020e911f12c9
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "png" CMAKE_DISABLE_FIND_PACKAGE_lodepng-c
        "sdl" CMAKE_DISABLE_FIND_PACKAGE_SDL2
        "threads" CMAKE_DISABLE_FIND_PACKAGE_Threads
        "unicode" CMAKE_DISABLE_FIND_PACKAGE_utf8proc
        "unicode" CMAKE_DISABLE_FIND_PACKAGE_unofficial-utf8proc
        "zlib" CMAKE_DISABLE_FIND_PACKAGE_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_INSTALL_INCLUDEDIR=${CURRENT_PACKAGES_DIR}/include
        -DLIBTCOD_SDL2=find_package
        -DLIBTCOD_ZLIB=find_package
        -DLIBTCOD_LODEPNG=find_package
        -DLIBTCOD_UTF8PROC=vcpkg
        -DLIBTCOD_STB=find_package
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
