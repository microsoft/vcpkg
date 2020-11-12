# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO efficient/libcuckoo
    REF 8785773896d74f72b6224e59d37f5f8c3c1e022a
    SHA512 e47f8fd132ee2acf347ee375759f96235cd090fdb825792f994ff5eb4d8fed55b8e8bea8d293ec96c1a5f1b46d19c6648eaf2482e482b7b9c0d6dc734bc2121d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_STRESS_TESTS=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_UNIVERSAL_BENCHMARK=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
