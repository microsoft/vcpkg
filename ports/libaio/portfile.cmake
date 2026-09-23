vcpkg_download_distfile(ARCHIVE
    URLS "https://releases.pagure.org/libaio/libaio-${VERSION}.tar.gz"
    FILENAME "libaio-${VERSION}.tar.gz"
    SHA512 65c30a102433bf8386581b03fc706d84bd341be249fbdee11a032b237a7b239e8c27413504fef15e2797b1acd67f752526637005889590ecb380e2e120ab0b71
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/pkgconfig.pc.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERSION=${VERSION}
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")