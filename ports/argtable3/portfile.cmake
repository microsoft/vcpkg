# We cannot use vcpkg_from_github to download the source archive because the
# auto-generated GitHub archive does not include the `version.tag` file. This
# file is required to generate argtable3.pc with the correct version info.
# To resolve this, we prepare the source archive manually and use
# vcpkg_download_distfile to download it.

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/argtable/argtable3/releases/download/v${VERSION}/argtable-v${VERSION}.zip"
    FILENAME "argtable-v${VERSION}.zip"
    SHA512 5591d510a1c739148aa356e5fa9827e037c4a0f1d171453635fad0cca4030d1fa3cce1e50671a944d12abfd4793df1f5cd1125825a23c63e54e9362def56e9f9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGTABLE3_ENABLE_CONAN=OFF
        -DARGTABLE3_ENABLE_TESTS=OFF
        -DARGTABLE3_ENABLE_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
