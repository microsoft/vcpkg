vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenBluetoothToolbox/SimpleBLE
    REF "v${VERSION}"
    HEAD_REF main
    SHA512 bf9b166340df6620fcafe7e453795bc314769aed49c5284b425ea90b064a9d242432625f544ea6f79441e36c1b9ed5909dfc80d1e69c102ce27589cc09f02417
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/simpleble"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DLIBFMT_VENDORIZE=OFF
)

vcpkg_cmake_install()

#vcpkg_copy_pdbs()

#vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

#vcpkg_fixup_pkgconfig()

#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

#file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)