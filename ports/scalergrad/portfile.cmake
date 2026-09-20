vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tamalckb531/scalergrad
    REF "v${VERSION}"
    SHA512 63bb62e3f365d787c14ebb4c4233652b6d148bea3d97da8c29113680ad73670ad51e47b9f0f34dc0962d8093e168ac905217abff2693396aea92c5344ead97dc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME scalergrad
    CONFIG_PATH lib/cmake/scalergrad
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/scalergrad" RENAME copyright)