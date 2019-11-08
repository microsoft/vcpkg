include(vcpkg_common_functions)

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
vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH})

vcpkg_configure_qmake(SOURCE_PATH
    ${SOURCE_PATH}/qcustomplot-sharedlib/sharedlib-compilation/sharedlib-compilation.pro
)

vcpkg_build_qmake(
    RELEASE_TARGETS release-all
    DEBUG_TARGETS debug-all
)

set(DEBUG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(RELEASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

# Install header file
file(INSTALL ${SOURCE_PATH}/qcustomplot.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Install module files
macro(_install_module_file source_dir target_dir filename_regex)
    file(GLOB _files ${source_dir}/*)
    list(FILTER _files INCLUDE REGEX ${filename_regex})
    file(INSTALL ${_files} DESTINATION ${target_dir})
endmacro()

_install_module_file(${DEBUG_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/debug/lib
    "qcustomplotd[2]*\.(lib|a)$")

_install_module_file(${RELEASE_DIR}/release
    ${CURRENT_PACKAGES_DIR}/lib
    "qcustomplot[2]*\.(lib|a)$")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(INSTALL
        ${DEBUG_DIR}/debug/qcustomplotd2.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )

    file(INSTALL
        ${RELEASE_DIR}/release/qcustomplot2.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
endif()

vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/GPL.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
