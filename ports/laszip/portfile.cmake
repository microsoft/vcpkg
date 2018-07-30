include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/laszip-src-3.2.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/LASzip/LASzip/releases/download/3.2.2/laszip-src-3.2.2.tar.gz"
    FILENAME "laszip-src-3.2.2.tar.gz"
    SHA512 e89707c0569c6435394a3a07ba5e6ea972d65cf793c157a698d1ec293f5477deccd613733cb544b907d6c1f13d0313f0d24ae7e5dddc426d7bdb9a7e58709cf8
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/laszip RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Remove laszip_api3 dll since it doesn't export functions properly during build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/laszip_api3.dll)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/laszip_api3.dll)
