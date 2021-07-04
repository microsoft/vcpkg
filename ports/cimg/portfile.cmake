vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "dtschump/CImg"
    REF a0e7ecb55130bdf90756033c1e1470eae4b88c1a #v2.9.4
    HEAD_REF master
    SHA512 0fc814b67ce9f035a68308850117b40cb54d731cb559bf1b6f46e1ec1e29d473e805818018ac411529b51510468cfbe4427aa52a354f919d7f1ce84bd285a47d)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Move cmake files, ensuring they will be 3 directories up the import prefix
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/Licence_CeCILL-C_V1-en.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/Licence_CeCILL_V2-en.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright2)
