vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF 9e55cea0116febb5c536ed18ede9a7b2c647e631 # 7.3.1
    SHA512 22da46c1c4ef798e7aa2db4f5094f8d4c3a965d755ae72a1cfae6282264c0d974317849f8db0bf34ff6aebd1ede5e5086cf74bff8bc3c6a21b3149a94d30c04f
    HEAD_REF master
    PATCHES
        fix-build-with-vs2017.patch #https://github.com/jtv/libpqxx/pull/406
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/config-public-compiler.h.in DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config-internal-compiler.h.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSKIP_BUILD_TEST=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libpqxx)
file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
