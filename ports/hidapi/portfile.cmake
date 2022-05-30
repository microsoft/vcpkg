vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF hidapi-0.12.0
    SHA512 0c4bc45706d99498950491091ba8a5e8ccdd3964
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DHIDAPI_BUILD_HIDTEST=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/hidapi/hidapi.cmake" "\"/hidapi\"" "\"\${_IMPORT_PREFIX}/include\"")

file(INSTALL "${SOURCE_PATH}/LICENSE-bsd.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
