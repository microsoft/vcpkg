vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Atliac/minitest
    REF v1.1.0
    SHA512 8fcafbb9fb066c212b8aea692ae8afe364b86110138ebc5bd43db3dc291f9adb5a107b67074ce47a3ed3b9f57a61526b24e49aeb133c7705bc33b70090042a06
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME minitest)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")