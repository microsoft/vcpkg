# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO johnmcfarlane/cnl
    REF 2dde6e62e608a4adc3c5504f067575efa4910568 #v1.1.7
    SHA512 33a81ea726802c71a684bcd002b5119cde4db471ebc9ba02cd15c7487ab468eeca09fb8dcaed953e3f3cded2cd813a903f808d97527b0ec7f393647b64a22572
    HEAD_REF main
    PATCHES
        disable-test.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE_1_0.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
