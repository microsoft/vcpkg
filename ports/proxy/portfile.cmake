vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/proxy
    REF ${VERSION}
    SHA512 901815cd4456ce73d129311c8bf81ab7c5d87f290893ad47698b632c7d31c8648e9616975c942d6599d906b073452aae6fcdeffaee8f5b790febaab8a7fa4a6b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
