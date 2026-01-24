vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  sandialabs/verdict
    REF ${VERSION}
    SHA512 e4a38fabcb7b56cbc50b59ee2d97c8a4cc3a2afea6ec22860005b77b79536a8dae16acef48197ae881f5b6dbd20495c16ba5b3eadd57d7d478482e5734a98b1d
    HEAD_REF master
    PATCHES include.patch
            fix_osx.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERDICT_ENABLE_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/verdict" PACKAGE_NAME verdict)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

