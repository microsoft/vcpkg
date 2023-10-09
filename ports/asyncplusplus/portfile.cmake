vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Amanieu/asyncplusplus
    REF 172ca3f8e0df1b3f7f5ee8b8244e4ac67258b0d8 # v1.1
    SHA512 fd95b3349ceed4cab5cb0e146d2ccfe77c85318303015cf513037fc69c1ade7cfdb3dc81de8a90846c4387c5e31f5a70a64da770547c201dfe24d2c181be1933
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME async++)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
