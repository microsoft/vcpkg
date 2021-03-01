vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF 1.16.4
    SHA512  559e1b905dd79a5f1bb5abd95b0beee3b9749a8663cc1eadc824f83d30082bf14ad73a9a4f7001464357b6977a221246eced25ebd63a6400f995b012f9100790
    HEAD_REF develop
    PATCHES fix-dependencies.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_INSTALL_INCLUDEDIR=${CURRENT_PACKAGES_DIR}/include
        -DCMAKE_INSTALL_CONFIGDIR=share/libtcod
        -DLIBTCOD_SDL2=find_package
        -DLIBTCOD_ZLIB=find_package
        -DLIBTCOD_GLAD=find_package
        -DLIBTCOD_LODEPNG=find_package
        -DLIBTCOD_UTF8PROC=vcpkg
        -DLIBTCOD_STB=vcpkg
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

file(
    INSTALL "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
