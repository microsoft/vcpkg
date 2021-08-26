vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF 221ddc8be329bafb376a3d83b9cd257fd52fc7b7 # 7.6.0
    SHA512 32a673bbae2f26fbc41bdcba007d9a5ded29680cb49ba434d1913cd5007bc1c1443bf38c88d9c5a6abe0a3ee519c0f691464c8d2b144cd3f16652447d644e400
    HEAD_REF master
    #PATCHES
    #    fix-build-with-vs2017.patch #https://github.com/jtv/libpqxx/pull/406
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
