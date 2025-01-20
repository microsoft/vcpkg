vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomen/transwarp
    REF "${VERSION}"
    SHA512 f420a74513b1b1dfd1cba3e2447f3832098f75c6e9a5f7aff3a7b2567ddca07646d49c90b377299642443dadd968dc98695661a1db33f9426e112559a83f2154
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
