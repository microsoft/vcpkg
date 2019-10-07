include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} currently only supports being built for desktop")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v12.0/postgresql-12.0.tar.bz2"
    FILENAME "postgresql-12.0.tar.bz2"
    SHA512 231a0b5c181c33cb01c3f39de1802319b79eceec6997935ab8605dea1f4583a52d0d16e5a70fcdeea313462f062503361d543433ee03d858ba332c72a665f696
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES make gcc)
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --with-openssl
        CC=${MSYS_ROOT}/usr/bin/gcc.exe
    OPTIONS_DEBUG
        --enable-debug
)
vcpkg_install_make()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpq RENAME copyright)
