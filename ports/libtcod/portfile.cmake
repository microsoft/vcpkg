vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF ${VERSION}
    SHA512 7aa0a355937c70a49975f1f131e8cb8dd62ac5c880f4a2ad2a4c51cfdd87a60341160dfaf4c42d5a8c7d77316e4084d62d0baa2ff5abecee47b5413fd161ebad
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "png" CMAKE_DISABLE_FIND_PACKAGE_lodepng-c
        "sdl" CMAKE_DISABLE_FIND_PACKAGE_SDL3
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
        -DLIBTCOD_SDL3=find_package
        -DLIBTCOD_ZLIB=find_package
        -DLIBTCOD_LODEPNG=find_package
        -DLIBTCOD_UTF8PROC=vcpkg
        -DLIBTCOD_STB=find_package
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
