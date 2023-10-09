vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kuba--/zip
    REF 42151612e8546c55485ec38cf0d57e57e51a8abd #v0.2.4
    SHA512 9cbb7bcb8095c365c4529f06c883f3aa0c1038ed3aa6a0419dafb90355abf6e5cd02f7ffd5cbb54fe3893102bb21f568d415b71500630ad203a1f911b6e52ef5
    HEAD_REF master
    PATCHES
        fix_targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/kubazip)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/UNLICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
