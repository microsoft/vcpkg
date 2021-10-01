# NOTE: update the version and checksum for new LIBRTTOPO release
set(LIBRTTOPO_VERSION_STR "1.1.0")
set(LIBRTTOPO_PACKAGE_SUM "d9c2f4db1261cc942152d348abb7f03e6053a63b6966e081c5381d40bbebd3c7ca1963224487355f384d7562a90287fb24d7af9e7eda4a1e230ee6441cef5de9")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.osgeo.org/librttopo/src/librttopo-${LIBRTTOPO_VERSION_STR}.tar.gz"
    FILENAME "librttopo-${LIBRTTOPO_VERSION_STR}.tar.gz"
    SHA512 ${LIBRTTOPO_PACKAGE_SUM}
)

vcpkg_extract_source_archive_ex(
    ARCHIVE "${ARCHIVE}"
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        fix-makefiles.patch
        geos-config.patch
        fix-pc-file.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

  file(REMOVE "${SOURCE_PATH}/src/rttopo_config.h")
  configure_file("${CMAKE_CURRENT_LIST_DIR}/rttopo_config.h.in" "${SOURCE_PATH}/src/rttopo_config.h" @ONLY)

  vcpkg_build_nmake(
      SOURCE_PATH "${SOURCE_PATH}"
      TARGET librttopo.lib
  )

  file(GLOB LIBRTTOPO_INCLUDE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/headers/*.h")
  file(COPY ${LIBRTTOPO_INCLUDE} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

  file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/librttopo.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/librttopo.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
else() # Build in UNIX
  vcpkg_configure_make(
      SOURCE_PATH "${SOURCE_PATH}"
      AUTOCONFIG
      OPTIONS_DEBUG
          "--with-geosconfig=${CURRENT_INSTALLED_DIR}/tools/geos/debug/bin/geos-config"
      OPTIONS_RELEASE
          "--with-geosconfig=${CURRENT_INSTALLED_DIR}/tools/geos/bin/geos-config"
  )
  vcpkg_install_make()
  vcpkg_fixup_pkgconfig()
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
