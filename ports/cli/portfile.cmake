vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO daniele77/cli
    REF "v${VERSION}"
    SHA512 6f9cd55fb1dd9a3b096bdf7c1143944281c858e78c52e2316a162dc78953d0037a824c41f9aa6cf17f331d7300773696e63b2c6b1f12d2408d26780d596e1043
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
