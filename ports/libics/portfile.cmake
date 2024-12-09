vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svi-opensource/libics
    REF "${VERSION}"
    SHA512 0eba280c1174cbd0e1fe6da1502345720793df2f3f6ec31fe0043d79a31d7b79cac5d7da726891faacedc91056e6337a3a694e50d0baafa08314a2867ff3e62f
    HEAD_REF master
    PATCHES fix-integral-include.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/GNU_LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
