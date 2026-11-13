vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF "${VERSION}"
    SHA512 b79095a4663e3e90001636346f05e7ca68434ff4eada4a2cda3991b18867efae453abe2750960722ef558edca56e66c08fefddb7bd717648a472cadb57b11da6
    HEAD_REF main
    PATCHES
        pkgconfig.patch
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
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
