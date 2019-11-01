include(vcpkg_common_functions)


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yse/easy_profiler
    REF 91d10c2b464256e1838349478d92f8f8014d1f54
    SHA512 2caf997d1799cae4dd19ecb9cf1e09a5f4445dd1aa3fd6ebf349f56a18bf49df9d916285001aa0266a3d972e1b46c85a6ffb58a1034a8c5f8f1221a92b00f879
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/easy_profiler RENAME copyright)

vcpkg_copy_pdbs()
