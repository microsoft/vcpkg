vcpkg_download_distfile(ARCHIVE
    URLS "https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${VERSION}.tar.xz"
         "https://www.mirrorservice.org/sites/ftp.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${VERSION}.tar.xz"
    FILENAME "libcap-${VERSION}.tar.xz"
    SHA512 647c307dc451517da9d089495ab959b4a6fbbe41c79f4e1e9bb663569dad630ead0c2e413dfb393319e3ea14dc9848c81b392107fe3382ce1813d278c3394a7f
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
