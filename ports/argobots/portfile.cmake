vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/pmodels/argobots/releases/download/v${VERSION}/argobots-${VERSION}.tar.gz"
    FILENAME "argobots-${VERSION}.tar.gz"
    SHA512 e3584765a4eac0c6ec87b3ebcd061f90a630c022e30b5817d8f2577ecc233da3512306542b7d97d3b3bfe74bb6ece6fa9b24bdbe2483b43a7bc6b2cbd4f2513a
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
