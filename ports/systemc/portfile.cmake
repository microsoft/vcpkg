vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SYSTEMC_VERSION 2.3.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.accellera.org/images/downloads/standards/systemc/systemc-${SYSTEMC_VERSION}.zip"
    FILENAME "systemc-${SYSTEMC_VERSION}.zip"
    SHA512 f4df172addf816a1928d411dcab42c1679dc4c9d772f406c10d798a2c174d89cdac7a83947fa8beea1e3aff93da522d2d2daf61a4841ec456af7b7446c5c4a14
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SYSTEMC_VERSION}
    PATCHES
        install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DDISABLE_COPYRIGHT_MESSAGE=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SystemCLanguage TARGET_PATH share/systemclanguage)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/SystemCTLM TARGET_PATH share/systemctlm)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/sysc/packages/qt/time)

file(INSTALL ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/systemc RENAME copyright)
