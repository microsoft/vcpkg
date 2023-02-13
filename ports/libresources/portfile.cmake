vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO as-shura/libresources
    REF master
    SHA512 609970c9f4c2723688d8be7976e9e8c7abc78605281bcee4c744099f93c580506ea90f760d685d91bf79af4c5f9f3cdc79ab9e1b86b5fb94ed3f1431f5f4348e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME libresources CONFIG_PATH lib/cmake/libresources)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)



