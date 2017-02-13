include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libnice-0.1.13)

vcpkg_download_distfile(ARCHIVE
    URLS "https://nice.freedesktop.org/releases/libnice-0.1.13.tar.gz"
    FILENAME "libnice-0.1.13.tar.gz"
    SHA512 c9bb81e8cd0b4e3673dba07ce08a16dd8821831339b44f1006510cdc09f9ae4c6eb7d43230711a2509867acb8d7df71821c411830dbf71c5a5d7e802f14a32c1
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_RELEASE -DOPTIMIZE=1
    OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libnice)
file(COPY ${SOURCE_PATH}/COPYING.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/libnice)
file(COPY ${SOURCE_PATH}/COPYING.MPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/libnice)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libnice/COPYING ${CURRENT_PACKAGES_DIR}/share/libnice/copyright)
