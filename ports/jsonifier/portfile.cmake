vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"    
    SHA512 50f8c244c87bc038251ef13574ae86ce20ca1df9ef1c8fc8de5ebade038a60bb8b98528ce6c978ffe4e0f24b12959a650e8ef5d3c53bcdbd1f187b6cae18493a
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
