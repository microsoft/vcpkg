set(LIBTOOL_VERSION_STR "2.4.7")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/libtool/libtool-${LIBTOOL_VERSION_STR}.tar.xz"
    FILENAME "gnu-libtool-${LIBTOOL_VERSION_STR}.tar.xz"
    SHA512 47f4c6de40927254ff9ba452612c0702aea6f4edc7e797f0966c8c6bf0340d533598976cdba17f0bdc64545572e71cd319bbb587aa5f47cd2e7c1d96f873a3da
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_list(SET OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    string(APPEND VCPKG_C_FLAGS " -D_CRT_SECURE_NO_WARNINGS")
    string(APPEND VCPKG_CXX_FLAGS " -D_CRT_SECURE_NO_WARNINGS")
    if(NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_list(APPEND OPTIONS
            ac_cv_header_dirent_h=no # Ignore vcpkg port dirent
        )
    endif()
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}/libltdl"
    AUTOCONFIG
    OPTIONS
        --enable-ltdl-install
        ${OPTIONS}
)
vcpkg_install_make()

file(INSTALL "${SOURCE_PATH}/libltdl/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
