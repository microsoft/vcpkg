vcpkg_download_distfile(ARCHIVE
    URLS "https://www.qcustomplot.com/release/${VERSION}/QCustomPlot.tar.gz"
    FILENAME "QCustomPlot-${VERSION}.tar.gz"
    SHA512 2e49a9b3f7ab03bcd580e5f3c3ae0d5e8c57d3ccce0ceed9862cde7ea23e2f3672a963af988be60e504cb5aa50bc462e4b28acf577eae41cc6fea2802642dc19
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.qcustomplot.com/release/${VERSION}/QCustomPlot-sharedlib.tar.gz"
    FILENAME "QCustomPlot-sharedlib-${VERSION}.tar.gz"
    SHA512 c661e4a835066fee92b254fbd7b825dbd5c58973189ff2099a01308cb81fe6bf3bac1456f5da91f01c6265f8f548f61b57e237d00a9b5c2c94acf1a024baa18e
)
vcpkg_extract_source_archive(
    SharedLib_SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        config.patch
)
file(RENAME "${SharedLib_SOURCE_PATH}" "${SOURCE_PATH}/qcustomplot-sharedlib")

vcpkg_qmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/qcustomplot-sharedlib/sharedlib-compilation/sharedlib-compilation.pro"
    QMAKE_OPTIONS
        "${OSX_OPTIONS}"
)
vcpkg_qmake_install()

vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/GPL.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
