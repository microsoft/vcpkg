vcpkg_download_distfile(ARCHIVE 
    URLS
        "https://ftpmirror.gnu.org/guile/guile-${VERSION}.tar.gz"    
        "https://ftp.gnu.org/gnu/guile/guile-${VERSION}.tar.gz"
    FILENAME "guile-${VERSION}.tar.gz"
    SHA512 bf81eca9554d22dcfcff4797739dee18758c257bd2c848fdf508e3fd6e58ffd9754b08a57d8ba31c80a69b0444fff3b045e22ec88fc34ef787cd71f5466fafe8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    ADD_BIN_TO_PATH
    AUTOCONFIG
)
vcpkg_install_make()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

if (NOT VCPKG_BUILD_TYPE)
    foreach(file guile-tools guile-config guild)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/${file}" "${CURRENT_INSTALLED_DIR}/debug/../tools/guile/debug/bin" "`dirname $0`" IGNORE_UNCHANGED)
    endforeach()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/guile-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()
foreach(file guile-tools guile-config guild)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${file}" "${CURRENT_INSTALLED_DIR}/tools/guile/bin" "`dirname $0`" IGNORE_UNCHANGED)
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/guile-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LESSER")
