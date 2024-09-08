vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"    
    SHA512 1fb75aaac54e8ebfc443885b53f4b150023dc963c4bab853ce0c171f83b074bb6768d9560eca6fdc08bd4eac9ea8b7232addfb9938b253332eb183844ee2ede3
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
