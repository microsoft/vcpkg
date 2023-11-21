
vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO dtschump/CImg
    REF d6c022169271fa3c73abf94002a557c4e6f8327f #v3.3.2
    SHA512 0cb2e0cc41902bdb3a21bac079104d4c49bbf51ae0eef6497fdb645934311aa75480bffcc2fc9d11c5b54912397fb4910c4c20ccd766a83e317a8e861b9b513b
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

vcpkg_install_copyright(
    FILE_LIST 
        "${SOURCE_PATH}/Licence_CeCILL-C_V1-en.txt"
        "${SOURCE_PATH}/Licence_CeCILL_V2-en.txt"
)
