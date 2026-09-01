vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihilai-collective/jsonifier
    REF "v${VERSION}"
    SHA512 259b9b90aa093e1c6c79ddc1867199cc0256b3ac2066d4ea1606ba7727cc73c9bb690c4c4f27820098fad7c5bb339db6bbc00e6a3aa97427cd18b1f781ca502f
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md" "${SOURCE_PATH}/Third_Party_Licenses.md")
