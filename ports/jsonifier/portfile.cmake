vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"
    SHA512 6b7af20a5cfedd98200e537b284d513f8ee964d76c28d8f01cdc40e324f051b3fa48c2d68ddc92c8dd2ed494b807b4dfdaca25430fc4f6bf68b9e9a8fc9a8644
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
