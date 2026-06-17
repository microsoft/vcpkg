vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/benchmarksuite
    REF "v${VERSION}"    
    SHA512 5f10d9c9b57d1e6e8826516ed6fd04af78360731cda378e379ea7d1a8ce651c00558d19722e80129539498a55ecadf13ac7e75b13cedeaee3174805eba026955
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
