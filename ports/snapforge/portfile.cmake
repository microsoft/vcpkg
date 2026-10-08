# Public immutable SDK tarball: never pull source from the private commercial repository.
vcpkg_download_distfile(ARCHIVE
    URLS "https://snapforge.web-tasarimci.com/cpp-releases/snapforge-0.2.0.tar.gz"
    FILENAME "snapforge-0.2.0.tar.gz"
    SHA512 679c27c14ad42ce7812d50f92c951446f0696a98c64ffb9f65dbe3f2e5968d0aba60cffa2b68dd6c1bb4c6a1f13aeecdfe9f26e836bd20e58d52515be1c4d3d5
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DSNAPFORGE_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME SnapForge CONFIG_PATH lib/cmake/SnapForge)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
