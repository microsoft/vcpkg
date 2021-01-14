vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF 58d2a028d1600225ac3a478d6b3a06ba2f0c01f6 # 7.3.0
    SHA512 c0c121e89e8b6669cd049a25c8b647d7cb861868da4daa11fc68e6a3a9384c22b9bc16e09c998389bc769aae36e618097cc93ca9f90822d90f8c0d15871ec1b0
    HEAD_REF master
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
