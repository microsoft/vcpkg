vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF hidapi-0.13.1
    SHA512 07b224b9b5146caf693e6d67514fed236436ed68f38a3ada98ebf8352dfaa4e175f576902affb4b79da1bb8c9b47a1ee0831a93c7d3d210e93faee24632f7d53
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

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/hidapi/libhidapi.cmake" "\"/hidapi\"" "\"\${_IMPORT_PREFIX}/include\"")

file(INSTALL "${SOURCE_PATH}/LICENSE-bsd.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
