vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edrosten/fast-C-src
    REF 391d5e939eb1545d24c10533d7de424db8d9c191
    SHA512 d6f401e2f80193c4f1f99e1ef59af7107d674c515574cf513c5977c4c95c49c0520d2a6e6787f617b42d9e3bd93c78b8fa7f1d8dc8901351820590078e62130e
    HEAD_REF master
)


file(COPY
"${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
"${CMAKE_CURRENT_LIST_DIR}/fastfeat.def"
DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/fastfeat" RENAME copyright)
