vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF 29f8c73492a1bfdf87fda77351c7356ebee5ecde  #v7.1.2
    SHA512 64fb6f62475c593430e3c6b6ad45f03b172b5efe3f51e2714334ca19303c436fab0ae70e1c5b462c3fcabbc74fc43da396ec1464c695c1fe1c89c904f3940848
    HEAD_REF master
    PATCHES
        fix-connect.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config-public-compiler.h.in DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config-internal-compiler.h.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
