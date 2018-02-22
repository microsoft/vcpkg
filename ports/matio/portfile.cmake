include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF v1.5.11
    SHA512 f500475e80cdb52a4754c49e900a34c0b540a5c64f353287e6b85b0c16156b251fe8088f2ed584af5a4d0916e98fddf73a3799e7c045ab859298687038e6d513
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})



vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/matio RENAME copyright)

vcpkg_copy_pdbs()
