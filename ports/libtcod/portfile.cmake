vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF ${VERSION}
    SHA512 e10d6d83e6057336efcc3f2a45dd7d2e287217c3c42f99f594a357668bac89dd8a235d8498d879168418c3b5fc1a3cb5ae2c9e0acadf4e3f95e247da3ab4de40
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "png" LIBTCOD_LODEPNG
        "png" VCPKG_LOCK_FIND_PACKAGE_lodepng-c
        "sdl" LIBTCOD_SDL3
        "sdl" VCPKG_LOCK_FIND_PACKAGE_SDL3
        "threads" LIBTCOD_THREADS
        "threads" VCPKG_LOCK_FIND_PACKAGE_Threads
        "unicode" LIBTCOD_UTF8PROC
        "unicode" VCPKG_LOCK_FIND_PACKAGE_utf8proc
        "zlib" LIBTCOD_ZLIB
        "zlib" VCPKG_LOCK_FIND_PACKAGE_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_INSTALL_INCLUDEDIR=${CURRENT_PACKAGES_DIR}/include
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Stb=ON
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_SDL3
        VCPKG_LOCK_FIND_PACKAGE_Threads
        VCPKG_LOCK_FIND_PACKAGE_ZLIB
        VCPKG_LOCK_FIND_PACKAGE_lodepng-c
        VCPKG_LOCK_FIND_PACKAGE_utf8proc
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
