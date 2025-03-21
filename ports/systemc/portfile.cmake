vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SYSTEMC_VERSION 2.3.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/accellera-official/systemc/archive/refs/tags/${SYSTEMC_VERSION}.tar.gz"
    FILENAME "systemc-${SYSTEMC_VERSION}.tar.gz"
    SHA512 3ef4b5e9c05b8d03e856598ddc27ad50a0a39a7f9334cd00faefeacdf954b6527104d3238c4e8bfa88c00dc382f4da5a50efbd845fe0b6cc2f5a025c993deefd
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
