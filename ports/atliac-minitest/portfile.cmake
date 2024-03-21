vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Atliac/minitest
    REF "v${VERSION}"
    SHA512 3c15a2fff59c5050eaa995da10fa57ee4c414dda75f5d2801c1defcc0dd7096d24f831a57c6bf059b971275d3369b3b9283aa1de738a5b7ce322008a50c4e3d7
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME atliac-minitest)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
