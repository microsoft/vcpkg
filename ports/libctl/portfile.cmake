vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/NanoComp/libctl/releases/download/v4.5.1/libctl-4.5.1.tar.gz"
    FILENAME "libctl-4.5.1.tar.gz"
    SHA512 384e0f22c53654c0817e73436e24bb58227ba7617fefd4c128bb124e98a40c00f755c0e637c04e6e0f6d29ce2dfdf15f7161b5226c420a7369bede1b06ac2ec0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --without-guile
    OPTIONS_DEBUG
        --enable-debug
)

vcpkg_install_make()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include/")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/")

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
