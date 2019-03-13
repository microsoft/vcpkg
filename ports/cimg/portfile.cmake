include(vcpkg_common_functions)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "dtschump/CImg"
    REF v.2.4.5
    HEAD_REF master
    SHA512 0a306ba4265a0e68d358e1ca54c597e80b43e72205de161d0971cd5837ca7d48322725d6ec129381e708a1d11fb5697884a5901ac753080fd8d8c08b80b28138)

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
