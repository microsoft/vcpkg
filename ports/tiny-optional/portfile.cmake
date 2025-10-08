set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sedeniono/tiny-optional
    REF "v${VERSION}"
    SHA512 d92394c20a12451c59b30a7bec446dce1be08a6aab2ed8527a6e23f04789be759b6f4eb83666d1985b2716df2031baeb84d5ec83d39ceaf43d7162921cb92d4a
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
