vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmocka/cmocka
    REF 672c5cee79eb412025c3dd8b034e611c1f119055
    SHA512 e02ffe780698ce3930aceb1b927f7d48c932c6bb251a32b1f4ab44ecb4ff6bfe5c2a6b9e2dfede49cd4cc1d68a8bb903ef1d26c28536abf3581a9d803287aa0a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_CMOCKERY_SUPPORT=ON
        -DUNIT_TESTING=OFF
        -DWITH_EXAMPLES=OFF
        -DPICKY_DEVELOPER=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
