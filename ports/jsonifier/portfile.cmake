vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihilai-collective/jsonifier
    REF "v${VERSION}"
    SHA512 f07c0e970ab19b5ffffd5da3576d9e063d9774bdb41e855e21c069cdca97eb72c6ae7b3ff8fc8134066c3442286c85854f46597d6f8ebb304a2770cf6a25bfd1
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md" "${SOURCE_PATH}/Third_Party_Licenses.md")
