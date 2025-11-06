vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/benchmarksuite
    REF "v${VERSION}"    
    SHA512 e4deaf511ba7754610d3abc7d624040cc9c89fc1a5bfe7b9e7d3a95bbf74719f80a6ad3c7d60ede27368143ec8d16a797286ad0ecddcbb7092420a6f7c65f419
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
