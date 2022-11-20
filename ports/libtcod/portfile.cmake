vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF 1.22.3
    SHA512 350b741f8738f5ba3c6f282e76c1124326144111eb2444b17b1126e8ddead52cff1dba1d0ed80e6fefbb0db8f032b95d08292d73746eec149e191a8fa78651d7
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "png" CMAKE_DISABLE_FIND_PACKAGE_lodepng-c
        "sdl" CMAKE_DISABLE_FIND_PACKAGE_SDL2
        "sdl" CMAKE_DISABLE_FIND_PACKAGE_GLAD
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
        -DLIBTCOD_GLAD=find_package
        -DLIBTCOD_LODEPNG=find_package
        -DLIBTCOD_UTF8PROC=vcpkg
        -DLIBTCOD_STB=find_package
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
