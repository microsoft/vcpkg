include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF fabac6cf3ab36dbb82bff747aa99016d7759ccc3
    SHA512 5aa77bced72e23b69692e28ff181f8a08ade25e356cf1ca327cf61c8a3f8f4a468e907090deae104ecff28f997806a8605168b034121f1d8c0a125b750911e83
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/matio RENAME copyright)

vcpkg_copy_pdbs()
