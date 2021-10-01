set(QCP_VERSION 2.0.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.qcustomplot.com/release/${QCP_VERSION}/QCustomPlot.tar.gz"
    FILENAME "QCustomPlot-${QCP_VERSION}.tar.gz"
    SHA512 a15598718146ed3c6b5d38530a56661c16269e530fe0dedb71b4cb2722b5733a3b57689d668a75994b79c19c6e61dcc133dbcb9ed77b93a165f4ac826a5685b9
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${QCP_VERSION}
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.qcustomplot.com/release/${QCP_VERSION}/QCustomPlot-sharedlib.tar.gz"
    FILENAME "QCustomPlot-sharedlib-${QCP_VERSION}.tar.gz"
    SHA512 ce90540fca7226eac37746327e1939a9c7af38fc2595f385ed04d6d1f49560da08fb5fae15d1b9d22b6ba578583f70de8f89ef26796770d41bf599c1b15c535d
)
vcpkg_extract_source_archive(SharedLib_SOURCE_PATH ARCHIVE "${ARCHIVE}")
file(RENAME "${SharedLib_SOURCE_PATH}" "${SOURCE_PATH}/qcustomplot-sharedlib")


vcpkg_configure_qmake(SOURCE_PATH
    ${SOURCE_PATH}/qcustomplot-sharedlib/sharedlib-compilation/sharedlib-compilation.pro
)

vcpkg_install_qmake(
    RELEASE_TARGETS release-all
    DEBUG_TARGETS debug-all
)

# Install header file
file(INSTALL ${SOURCE_PATH}/qcustomplot.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/GPL.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
