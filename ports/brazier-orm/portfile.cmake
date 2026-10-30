vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier-orm
    REF 388df77173a4d20d468af6a773767913f8fb647f
    SHA512 c4b31f2c5e5b354b8a2c33a7c50f278279c48f9adcfcfb23ba3c8d6e5ed580eadac8624f66cb1cac427bd836a020958f7f86e92c20cf8748bad230a76096fe1f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/brazier-orm"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_DEMO=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME brazier-orm CONFIG_PATH share/brazier-orm)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYING")
