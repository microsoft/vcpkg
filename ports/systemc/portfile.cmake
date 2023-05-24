vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SYSTEMC_VERSION 2.3.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.accellera.org/images/downloads/standards/systemc/systemc-${SYSTEMC_VERSION}.zip"
    FILENAME "systemc-${SYSTEMC_VERSION}.zip"
    SHA512 f4df172addf816a1928d411dcab42c1679dc4c9d772f406c10d798a2c174d89cdac7a83947fa8beea1e3aff93da522d2d2daf61a4841ec456af7b7446c5c4a14
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${SYSTEMC_VERSION}"
    PATCHES
        install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DDISABLE_COPYRIGHT_MESSAGE=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SystemCLanguage PACKAGE_NAME systemclanguage)
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/SystemCTLM PACKAGE_NAME systemctlm)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/sysc/packages/qt/time")

file(INSTALL "${SOURCE_PATH}/NOTICE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
