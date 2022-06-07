vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO daniele77/cli
    REF v2.0.1
    SHA512 cf91512bb960ead60b7a2a021e3851b998a2228f482a1a7921acb3e2ab4ff10e542c6c910997326b3e059cef7509223ec34077ce545d9af29d8903e8fecfd5ac
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cli)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_fixup_pkgconfig()
