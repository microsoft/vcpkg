set(FREEXL_VERSION_STR "1.0.4")

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-${FREEXL_VERSION_STR}.tar.gz"
    FILENAME "freexl-${FREEXL_VERSION_STR}.tar.gz"
    SHA512 d72561f7b82e0281cb211fbf249e5e45411a7cdd009cfb58da3696f0a0341ea7df210883bfde794be28738486aeb4ffc67ec2c98fd2acde5280e246e204ce788
)

vcpkg_extract_source_archive_ex(
  ARCHIVE "${ARCHIVE}"
  OUT_SOURCE_PATH SOURCE_PATH
  PATCHES
      fix-makefiles.patch
      fix-sources.patch
      fix-pc-file.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(LIBS_ALL_DBG 
      "\"${CURRENT_INSTALLED_DIR}/debug/lib/iconv.lib\" \
      \"${CURRENT_INSTALLED_DIR}/debug/lib/charset.lib\""
      )
    set(LIBS_ALL_REL 
      "\"${CURRENT_INSTALLED_DIR}/lib/iconv.lib\" \
      \"${CURRENT_INSTALLED_DIR}/lib/charset.lib\""
      )
    
    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS_DEBUG
            INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}/debug"
            INST_DIR="${CURRENT_PACKAGES_DIR}/debug"
            "LINK_FLAGS=/debug"
            "LIBS_ALL=${LIBS_ALL_DBG}"
        OPTIONS_RELEASE
            INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}"
            INST_DIR="${CURRENT_PACKAGES_DIR}"
            "LINK_FLAGS="
            "LIBS_ALL=${LIBS_ALL_REL}"       
    )
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
      file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
      file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
      file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/freexl_i.lib")
      file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/freexl_i.lib")
    else()
      file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/freexl.lib")
      file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/freexl.lib")
      if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/freexl_i.lib" "${CURRENT_PACKAGES_DIR}/lib/freexl.lib")
      endif()
      if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/freexl_i.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/freexl.lib")
      endif()
    endif()

else() # Build in UNIX

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
    )
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
