vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF 1.22.1
    SHA512 75fd804f4c970da6ffc084c896ab5e6d76527bf4e20d471ee50ac4e186e94e5a8dc8b68757f9bb46667147e2d3b2925f111749d3c865f3e82765b9de88d21e90
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "png" CMAKE_DISABLE_FIND_PACKAGE_lodepng-c
        "sdl" CMAKE_DISABLE_FIND_PACKAGE_SDL2
        "sdl" CMAKE_DISABLE_FIND_PACKAGE_GLAD
        "threads" CMAKE_DISABLE_FIND_PACKAGE_Threads
        "zlib" CMAKE_DISABLE_FIND_PACKAGE_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_INSTALL_INCLUDEDIR=${CURRENT_PACKAGES_DIR}/include
        -DLIBTCOD_SDL2=find_package
        -DLIBTCOD_ZLIB=find_package
        -DLIBTCOD_GLAD=find_package
        -DLIBTCOD_LODEPNG=find_package
        -DLIBTCOD_UTF8PROC=vcpkg
        -DLIBTCOD_STB=find_package
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
