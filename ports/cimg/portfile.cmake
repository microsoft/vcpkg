include(vcpkg_common_functions)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "dtschump/CImg"
    REF v.221
    HEAD_REF master
    SHA512 d1aea69f4662e85c5b56c723cadcc69282f2f1c4e3a968efc312a826a15000c11d61756d3ed87e37ae349cebbd62b67503996c45ed1fe038a91a9f0c8dbec43c)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Move cmake files, ensuring they will be 3 directories up the import prefix
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cimg)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/Licence_CeCILL-C_V1-en.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cimg RENAME copyright)
file(INSTALL ${SOURCE_PATH}/Licence_CeCILL_V2-en.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cimg RENAME copyright2)
