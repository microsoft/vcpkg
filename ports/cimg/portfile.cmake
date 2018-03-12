include(vcpkg_common_functions)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "dtschump/CImg"
    REF v.220
    HEAD_REF master
    SHA512 f4954296d7aab9ba840e27d09d4d9abc21d78bedc32bd828f3c898348de7c3711096c1b6ff563907dfa41c78d1ae1c2ac5a8437d272a8d304f940f23b7844076)

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
