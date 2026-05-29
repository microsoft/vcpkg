vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/benchmarksuite
    REF "v${VERSION}"    
    SHA512 abd4113842df376792cfde486e8cbff79163006177ca45cee72a916ce456c652b8b9692ad6efedccff66067713bc002a4a22d67873f358322a4fbc7688428f66
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
