vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF "v.${VERSION}"
    SHA512 ec9de55671ecd0d49fce3e677e11776306ec9ea993b06d67eaa3e5505ea171085c35aedea3cf29e03958b2c73f438c5ccd95539c75b63fd89c50d6367ccda1fe
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/dev/so_5_extra"
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/so5extra)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/so5extra" RENAME copyright)

