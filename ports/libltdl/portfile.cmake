vcpkg_download_distfile(ARCHIVE
    URLS "https://ftpmirror.gnu.org/libtool/libtool-${VERSION}.tar.xz"
         "https://ftp.gnu.org/pub/gnu/libtool/libtool-${VERSION}.tar.xz"
    FILENAME "gnu-libtool-${VERSION}.tar.xz"
    SHA512 eed207094bcc444f4bfbb13710e395e062e3f1d312ca8b186ab0cbd22dc92ddef176a0b3ecd43e02676e37bd9e328791c59a38ef15846d4eae15da4f20315724
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_list(SET OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    string(APPEND VCPKG_C_FLAGS " -D_CRT_SECURE_NO_WARNINGS")
    string(APPEND VCPKG_CXX_FLAGS " -D_CRT_SECURE_NO_WARNINGS")
    if(NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_list(APPEND OPTIONS ac_cv_header_dirent_h=no) # Ignore vcpkg port dirent
    endif()
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}/libltdl"
    AUTORECONF
    OPTIONS
        --enable-ltdl-install
        ${OPTIONS}
)
vcpkg_make_install()

file(COPY "${CURRENT_PORT_DIR}/libtoolize-ltdl-no-la" DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
file(CHMOD "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/libtoolize-ltdl-no-la" FILE_PERMISSIONS
    OWNER_READ OWNER_WRITE OWNER_EXECUTE
    GROUP_READ GROUP_EXECUTE
    WORLD_READ WORLD_EXECUTE
)
file(COPY "${CURRENT_PORT_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/libltdl/COPYING.LIB")
