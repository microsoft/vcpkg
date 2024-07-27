# NOTE: We don't use vcpkg_from_github as it does not
# include all the necessary source files
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-${VERSION}/cyrus-sasl-${VERSION}.tar.gz"
    FILENAME "cyrus-sasl-${VERSION}.tar.gz"
    SHA512 db15af9079758a9f385457a79390c8a7cd7ea666573dace8bf4fb01bb4b49037538d67285727d6a70ad799d2e2318f265c9372e2427de9371d626a1959dd6f78
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(REMOVE "${SOURCE_PATH}/include/md5global.h")
    file(COPY "${SOURCE_PATH}/win32/include/md5global.h" DESTINATION "${SOURCE_PATH}/include/md5global.h")
    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        DETERMINE_BUILD_TRIPLET
        PROJECT_NAME "NTMakefile"
        OPTIONS
            GSSAPI=MITKerberos
            "DB_INCLUDE=${CURRENT_INSTALLED_DIR}/include"
            "DB_LIB=libdb48.lib"
        OPTIONS_RELEASE
            CFG=Release
            "prefix=${CURRENT_PACKAGES_DIR}"
            "OPENSSL_LIBPATH=${CURRENT_INSTALLED_DIR}/lib"
            "DB_LIBPATH=${CURRENT_INSTALLED_DIR}/lib"
        OPTIONS_DEBUG
            CFG=Debug
            "prefix=${CURRENT_PACKAGES_DIR}/debug"
            "OPENSSL_LIBPATH=${CURRENT_INSTALLED_DIR}/lib/debug"
            "DB_LIBPATH=${CURRENT_INSTALLED_DIR}/lib/debug"
    )
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        DETERMINE_BUILD_TRIPLET
        OPTIONS
            "--with-gssapi"
            "--disable-macos-framework"
    )
    vcpkg_install_make()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
