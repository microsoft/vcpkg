vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/benchmarksuite
    REF "v${VERSION}"    
    SHA512 277f8e33d836c99c9a2f7b51e92c6c2df8bc549483118d77022a0776c493423975c118482b369c6fd728907fd76af02474d7d2d34ac9e335bb8314bed0866268
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
