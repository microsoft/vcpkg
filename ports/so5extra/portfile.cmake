include(vcpkg_common_functions)

set(VERSION 1.3.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sobjectizer/files/sobjectizer/so_5_extra/so5extra-${VERSION}.tar.bz2/download"
    FILENAME "so5extra-${VERSION}.tar.bz2"
    SHA512 58532426f85121f8f6c3b18a70950c048c8a695a7fca7be5d9c95434bdabdb2bfcf73d755737434a8d8aa5f3051785e13e7e293e057527c72047dad293a56ae7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev/so_5_extra
    PREFER_NINJA
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/so5extra)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/so5extra RENAME copyright)
