vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fix8mt/conjure_enum
    REF "v${VERSION}"
    SHA512 1eb201b7286f77176eb76fbb7d1e2236f9c689dadbbba1f73211c80bdfa04f3eb3a170b325115d54a9d0ddbb4789ee45c6952dd9c23688910bf919a7e19e4aa8
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/fix8 DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
