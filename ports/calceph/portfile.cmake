set(CALCEPH_VERSION "3.5.1")
set(CALCEPH_HASH 5e83bb46b92a0b53f2cae717363cb4497d5c9cb57b3903e70d9e2c50176ca7d234212d0209fd3fcb5feebfd0980313be17e2ad4e69482504bfe8686f93216b67)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-${CALCEPH_VERSION}.tar.gz"
    FILENAME "calceph-${CALCEPH_VERSION}.tar.gz"
    SHA512 ${CALCEPH_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

if (VCPKG_TARGET_IS_WINDOWS)

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        OPTIONS_DEBUG
            DESTDIR="${CURRENT_INSTALLED_DIR}/calceph/debug"
            CFLAGS="${VCPKG_C_FLAGS_DEBUG} "
        OPTIONS_RELEASE
            DESTDIR="${CURRENT_INSTALLED_DIR}/calceph"
            CFLAGS="${VCPKG_C_FLAGS_RELEASE} "
    )
    file(INSTALL "${CURRENT_INSTALLED_DIR}/calceph/include/calceph.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${CURRENT_INSTALLED_DIR}/calceph/lib/libcalceph.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
      file(INSTALL "${CURRENT_INSTALLED_DIR}/calceph/debug/lib/libcalceph.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
	file(REMOVE_RECURSE "${CURRENT_INSTALLED_DIR}/calceph")

else() # Build in UNIX
    vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
      --enable-fortran=no
      --enable-thread=yes
    )

    vcpkg_install_make()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

endif()

    file(INSTALL "${SOURCE_PATH}/README.rst" DESTINATION "${CURRENT_PACKAGES_DIR}/share/calceph" RENAME readme.rst)
    file(INSTALL "${SOURCE_PATH}/COPYING_CECILL_B.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/calceph" RENAME copyright)
    file(INSTALL "${SOURCE_PATH}/doc/calceph_c.pdf" DESTINATION "${CURRENT_PACKAGES_DIR}/share/calceph" RENAME calceph_c.pdf)
