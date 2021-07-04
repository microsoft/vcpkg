vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
set(OPTIONS -DSHARED=OFF)

set(METIS_VERSION 5.1.0)

vcpkg_download_distfile(ARCHIVE
    URLS "http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-${METIS_VERSION}.tar.gz"
    FILENAME "metis-${METIS_VERSION}.tar.gz"
    SHA512 deea47749d13bd06fbeaf98a53c6c0b61603ddc17a43dae81d72c8015576f6495fd83c11b0ef68d024879ed5415c14ebdbd87ce49c181bdac680573bea8bdb25
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${METIS_VERSION}
    PATCHES
        enable-install.patch
        disable-programs.patch
        fix-runtime-install-destination.patch
        fix-metis-vs14-math.patch
        fix-gklib-vs14-math.patch
        fix-linux-build-error.patch
        install-metisConfig.patch
        fix-INT_MIN_define.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/metis)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/metis)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
