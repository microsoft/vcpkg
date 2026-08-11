vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihilai-collective/jsonifier
    REF "v${VERSION}"
    SHA512 73e0e80ed36215468284b68700509ce20c17731483bbf5fc4c34c633a6090fbb418bbd02366edade335a4b0b8ba134087db49306fbcfe7db29c8990d17ce7158
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md" "${SOURCE_PATH}/Third_Party_Licenses.md")
