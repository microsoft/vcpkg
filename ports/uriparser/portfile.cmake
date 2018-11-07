include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uriparser/uriparser
    REF uriparser-0.9.0
    SHA512 d0a317fa55531f75b0e7ec712ea36f8e36a8cf72fdb4f959f3df7cc7c519d09752b194579a4f288bcea56d7be105da3d79dd8323960e74daff93f1dad2b5085d
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/uriparser RENAME copyright)
