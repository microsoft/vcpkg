vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF hidapi-0.11.2
    SHA512 c4d04bf570aa98dd88d7ce08ef1abb0675d500c9aa2c22f0437fa30b700a94446779f77e1170267926d5f6f0d9cdb2bb81ad1fe20d158c18587fddbca59e9517
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
