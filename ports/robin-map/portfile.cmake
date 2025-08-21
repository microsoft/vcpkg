vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF "v${VERSION}"
    SHA512 d65831ac9d1ae1b26d26386ee06835d788d18529d1cd9132f892091377572b2f9d68aaecfce79956238d327764fea7a144ad2922ced3cbe47cda8734b2df419f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME tsl-robin-map CONFIG_PATH share/cmake/tsl-robin-map)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
