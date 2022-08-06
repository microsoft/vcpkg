vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF 1.21.0
    SHA512 1d18a49b0d66337e2b29ad6b9a4a412cc4d2fd723d9a3d3c983ff3ef2f5bee4422ea3469513e0fe3b2f885773fb5d70e17128bc473b952ab6e0de27f687c905e
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "sdl" CMAKE_DISABLE_FIND_PACKAGE_SDL2
        "sdl" CMAKE_DISABLE_FIND_PACKAGE_GLAD
        "threads" CMAKE_DISABLE_FIND_PACKAGE_Threads
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
