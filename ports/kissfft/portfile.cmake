vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mborgerding/kissfft
    REF 8f47a67f595a6641c566087bf5277034be64f24d
    SHA512 ae39438b6d029296a440e1421f30731f371364107744fe9bad68e835e939f9a06d63016a99f5395a490ee0b1b1c33d46faafc651d91f13b8733d366e04dc861a
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/exports.def DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DKF_INSTALL_HEADERS=OFF
    OPTIONS_RELEASE
        -DKF_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-${PORT}
    CONFIG_PATH lib/cmake/unofficial-${PORT}
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
