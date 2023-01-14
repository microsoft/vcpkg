set(RHASH_XVERSION 1.4.2)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF 02c8b1dbae01c8d56613b6a3034c3698f94a52be # v1.4.2
    SHA512 4c1d0a91a758ba85bc9ea194cf148834d6a0ebd849ed5384444798c522723ad78c3eedf65e7460fba61989a69b2c0f9a0f12bd6583381c544778c4b1c199a4ba
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/librhash")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/librhash"
    OPTIONS_DEBUG
        -DRHASH_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-rhash)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
