vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/zip
    REF 24fadb2ed7780518ce11e3fde81e885ffd98575e # c89-vcpkg
    SHA512 4b81494b83ccf23aa8f1df32f39ebafd5df84b5f857e7b40cefa9fdafb5448f9f71f51eafdda36251ad104180e6d3d066783a340ae6c395d9e96c494e95680e1
    HEAD_REF c89-vcpkg
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_TESTING=ON
)

vcpkg_cmake_install()
#vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/zip" PACKAGE_NAME "zip-kuba--")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
