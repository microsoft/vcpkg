# portfile.cmake


vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tm24sense/libds4
    
    REF 5f493a0818801d371e929ab1aab1bac527d49d41
    SHA512 023e9299ab66998e58a3eb79e3592b839d23d44b93ed9e44f9953250e75177b6178621baec0c17144bc5e6bf3ac309f2ee3c6ce855369b007ee9702d278dee95
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)


vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(PACKAGE_NAME libds4)


vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")