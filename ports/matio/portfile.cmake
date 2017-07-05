include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF v1.5.10
    SHA512  c06ff6b3d17a136be20cebca4e1a4bb87eea98e35d979713e73f855487dee568895245528b1b8e55caf02f88aff1b742daf75f590e2d3b08158d0ad73e377243
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
