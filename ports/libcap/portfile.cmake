vcpkg_download_distfile(ARCHIVE
    URLS "https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/libcap-${VERSION}.tar.gz"
    FILENAME "libcap-${VERSION}.tar.gz"
    SHA512 b243ae403d45af2ff1204931b9e24c3b7f3e0c444f1ff2f3ed524c212b61a7ff1bc3c98df1855b2f0d300ebabf604b95440cdaddd666914ad60575e2e2f29fe8
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")

if(VCPKG_CROSSCOMPILING)
    file(TOUCH "${SOURCE_PATH}/libcap/_makenames")
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/include/sys/libcap-private/cap_names.list.h" DESTINATION "${SOURCE_PATH}/libcap/")
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/include/sys/libcap-private/cap_names.h" DESTINATION "${SOURCE_PATH}/libcap/")
    file(TOUCH "${SOURCE_PATH}/libcap/cap_names.h")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    DETERMINE_BUILD_TRIPLET
)
vcpkg_install_make(
    MAKEFILE "Makefile.vcpkg"
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")
