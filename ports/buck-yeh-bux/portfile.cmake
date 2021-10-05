vcpkg_fail_port_install(ON_ARCH "arm" "arm64")
vcpkg_fail_port_install(ON_TARGET "linux" "uwp" "osx")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF 7cd3bb2b563dbc907d64ade6dc66f1fcae282067 # v1.5.0
    SHA512 06ed00ce627a49dc9d36ac769e9b4a1851489248c57f24a4850ab28d0f2d63d2fc3e7b9712d954752e212476322b7a5f708838ed440364173b71a648dced2eb4
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
