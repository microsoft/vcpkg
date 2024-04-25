set(CALCEPH_HASH bbb60179b36f3ea9f05daa43e7950494d058137cf5a92e6c7b9742048dc0767490b7b42d2d2db7329f5ca96ffc4f2f32443abacb1073e29af78e58935b8b3edc)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-${VERSION}.tar.gz"
    FILENAME "calceph-${VERSION}.tar.gz"
    SHA512 ${CALCEPH_HASH}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
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
