set(SPATIALITE_TOOLS_VERSION_STR "5.0.0")
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/spatialite-tools-sources/spatialite-tools-${SPATIALITE_TOOLS_VERSION_STR}.tar.gz"
    FILENAME "spatialite-tools-${SPATIALITE_TOOLS_VERSION_STR}.tar.gz"
    SHA512 a1497824df2c45ffa1ba6b4ec53794c2c4779b6357885ee6f1243f2bff137c3e4dd93b0a802239ced73f66be22faf0081b83bf0ad4effb8a04052712625865d1
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-linux-configure.patch
        fix-makefiles.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
  if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
      set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib")
      set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib")
      set(LIBXML2_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib")
      set(LIBXML2_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib")
      set(SPATIALITE_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/spatialite.lib")
      set(SPATIALITE_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/spatialite.lib")
      set(ICONV_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/iconv.lib")
      set(ICONV_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/iconv.lib")
      set(EXPAT_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libexpat.lib")
      set(EXPAT_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libexpatd.lib")
  else()
      set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib ${CURRENT_INSTALLED_DIR}/lib/geos.lib")
      set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/geosd.lib")
      set(LIBXML2_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib ${CURRENT_INSTALLED_DIR}/lib/lzma.lib ws2_32.lib")
      set(LIBXML2_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib ${CURRENT_INSTALLED_DIR}/debug/lib/lzmad.lib ws2_32.lib")
      set(SPATIALITE_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/spatialite.lib ${CURRENT_INSTALLED_DIR}/lib/freexl.lib ${CURRENT_INSTALLED_DIR}/lib/librttopo.lib")
      set(SPATIALITE_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/spatialite.lib ${CURRENT_INSTALLED_DIR}/debug/lib/freexl.lib ${CURRENT_INSTALLED_DIR}/debug/lib/librttopo.lib")
      set(ICONV_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/iconv.lib ${CURRENT_INSTALLED_DIR}/lib/charset.lib")
      set(ICONV_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/iconv.lib ${CURRENT_INSTALLED_DIR}/debug/lib/charset.lib")
      set(EXPAT_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libexpatMD.lib")
      set(EXPAT_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libexpatdMD.lib")
  endif()

  if(VCPKG_TARGET_IS_UWP)
      set(UWP_LIBS windowsapp.lib)
      set(UWP_LINK_FLAGS /APPCONTAINER)
  endif()

  set(LIBS_ALL_DBG
      "${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib \
      ${CURRENT_INSTALLED_DIR}/debug/lib/readosm.lib \
      ${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib \
      ${LIBXML2_LIBS_DBG} \
      ${GEOS_LIBS_DBG} \
      ${ICONV_LIBS_DBG} \
      ${SPATIALITE_LIBS_DBG} \
      ${EXPAT_LIBS_DBG} \
      ${UWP_LIBS} \
      ${CURRENT_INSTALLED_DIR}/debug/lib/proj_d.lib ole32.lib shell32.lib"
  )
  set(LIBS_ALL_REL
      "${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib \
      ${CURRENT_INSTALLED_DIR}/lib/readosm.lib \
      ${CURRENT_INSTALLED_DIR}/lib/zlib.lib \
      ${LIBXML2_LIBS_REL} \
      ${GEOS_LIBS_REL} \
      ${ICONV_LIBS_REL} \
      ${SPATIALITE_LIBS_REL} \
      ${EXPAT_LIBS_REL} \
      ${UWP_LIBS} \
      ${CURRENT_INSTALLED_DIR}/lib/proj.lib ole32.lib shell32.lib"
  )

  file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR)
  list(APPEND OPTIONS_RELEASE
      "LINK_FLAGS=${UWP_LINK_FLAGS}" "INST_DIR=${INST_DIR}" "LIBS_ALL=${LIBS_ALL_REL}"
  )
  list(APPEND OPTIONS_DEBUG
      "LINK_FLAGS=/debug ${UWP_LINK_FLAGS}" "INST_DIR=${INST_DIR}\\debug" "LIBS_ALL=${LIBS_ALL_DBG}"
  )

  vcpkg_install_nmake(
      SOURCE_PATH ${SOURCE_PATH}
      OPTIONS
          "CL_FLAGS=/DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
      OPTIONS_RELEASE
          ${OPTIONS_RELEASE}
      OPTIONS_DEBUG
          ${OPTIONS_DEBUG}
  )

  list(APPEND TOOL_EXES
      shp_sanitize
      spatialite_osm_filter
      spatialite_osm_raw
      spatialite_gml
      spatialite_osm_map
      exif_loader
      spatialite_osm_net
      spatialite_network
      spatialite_tool
      shp_doctor
      spatialite
  )
  vcpkg_copy_tools(TOOL_NAMES ${TOOL_EXES} AUTO_CLEAN)

  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  if(VCPKG_TARGET_IS_LINUX)
      set(LIBS "-lpthread -ldl -lm -lz -lstdc++")
  else()
      set(LIBS "-lpthread -ldl -lm -lz -lc++ -liconv -lc")
  endif()

  list(APPEND OPTIONS_RELEASE
      "LIBXML2_LIBS=-lxml2 -llzma"
      "GEOS_LDFLAGS=-lgeos_c -lgeos"
  )
  list(APPEND OPTIONS_DEBUG
      "LIBXML2_LIBS=-lxml2 -llzmad"
      "GEOS_LDFLAGS=-lgeos_cd -lgeosd"
  )

  vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS
        "CFLAGS=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
        "LIBXML2_CFLAGS=-I\"${CURRENT_INSTALLED_DIR}/include\""
        "LIBS=${LIBS}"
        "--disable-minizip"
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
  )

  vcpkg_install_make()
  vcpkg_fixup_pkgconfig()
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
