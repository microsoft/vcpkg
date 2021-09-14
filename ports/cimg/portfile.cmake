vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO dtschump/CImg
    REF b33dcc8f9f1acf1f276ded92c04f8231f6c23fcd # v2.9.9
    SHA512 327c72320e7cac386ba72d417c45b9e8b40df34650370c34e687c362731919af1b447b2ee498f21278d4af155f0d9dbfabd222856d5f18c2e05569fa638a5909
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Move cmake files, ensuring they will be 3 directories up the import prefix
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/Licence_CeCILL-C_V1-en.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/Licence_CeCILL_V2-en.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright2)
