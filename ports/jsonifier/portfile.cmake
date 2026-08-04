vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihilai-collective/jsonifier
    REF "v${VERSION}"
    SHA512 f5f4d8b9c6ab8b5e116c4d328ad4044cf13f26efa2787d5a77f1047a579305f570400ee100721c9e47c8c74044b43123460c4d511c3c66ce895f263ab72fd39a
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
