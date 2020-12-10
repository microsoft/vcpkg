set(LIBSPATIALITE_VERSION_STR "5.0.0")
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    FILENAME "libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    SHA512 df72a3434d6e49f8836a9de2340f343a53f0673d0d17693cdb0f4971928b7c8bf40df44b21c0861945a9c81058e939acd1714b0b426ce9aa2ff7b0e8e6b196a7
)

if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_extract_source_archive_ex(
      OUT_SOURCE_PATH SOURCE_PATH
      ARCHIVE ${ARCHIVE}
      PATCHES
        fix-latin-literals.patch
        fix-makefiles.patch
  )

  if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CL_FLAGS_DBG "/MDd /Zi /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(CL_FLAGS_REL "/MD /Ox /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib")
    set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib")
    set(LIBXML2_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib")
    set(LIBXML2_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib")
    set(LIBRTTOPO_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/librttopo.lib")
    set(LIBRTTOPO_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/librttopo.lib")
  else()
    set(CL_FLAGS_DBG "/MTd /Zi /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(CL_FLAGS_REL "/MT /Ox /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib ${CURRENT_INSTALLED_DIR}/lib/geos.lib")
    set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/geosd.lib")
    set(LIBXML2_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib ${CURRENT_INSTALLED_DIR}/lib/lzma.lib ws2_32.lib")
    set(LIBXML2_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib ${CURRENT_INSTALLED_DIR}/debug/lib/lzmad.lib ws2_32.lib")
    set(LIBRTTOPO_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/librttopo.lib")
    set(LIBRTTOPO_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/librttopo.lib")
  endif()

  set(LIBS_ALL_DBG
    "${CURRENT_INSTALLED_DIR}/debug/lib/iconv.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/charset.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/freexl.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib \
    ${LIBXML2_LIBS_DBG} \
    ${GEOS_LIBS_DBG} \
    ${LIBRTTOPO_LIBS_DBG} \
    ${CURRENT_INSTALLED_DIR}/debug/lib/proj_d.lib ole32.lib shell32.lib"
  )
  set(LIBS_ALL_REL
    "${CURRENT_INSTALLED_DIR}/lib/iconv.lib \
    ${CURRENT_INSTALLED_DIR}/lib/charset.lib \
    ${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib \
    ${CURRENT_INSTALLED_DIR}/lib/freexl.lib \
    ${CURRENT_INSTALLED_DIR}/lib/zlib.lib \
    ${LIBXML2_LIBS_REL} \
    ${GEOS_LIBS_REL} \
    ${LIBRTTOPO_LIBS_REL} \
    ${CURRENT_INSTALLED_DIR}/lib/proj.lib ole32.lib shell32.lib"
  )

  string(REPLACE "/" "\\\\" INST_DIR ${CURRENT_PACKAGES_DIR})
  list(APPEND OPTIONS_RELEASE
    "LINK_FLAGS=" "INST_DIR=${INST_DIR}" "CL_FLAGS=${CL_FLAGS_REL}" "LIBS_ALL=${LIBS_ALL_REL}"
  )
  list(APPEND OPTIONS_DEBUG
    "LINK_FLAGS=/debug" "INST_DIR=${INST_DIR}\\debug" "CL_FLAGS=${CL_FLAGS_DBG}" "LIBS_ALL=${LIBS_ALL_DBG}"
   )

  vcpkg_install_nmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_RELEASE
      ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
      ${OPTIONS_DEBUG}
  )

  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib)
  else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/spatialite.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib ${CURRENT_PACKAGES_DIR}/lib/spatialite.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib)
  endif()
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
      fix-latin-literals.patch
      fix-linux-configure.patch
  )

  list(APPEND OPTIONS_RELEASE
    "CFLAGS=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
    "LIBS=-lpthread -ldl -lstdc++ -lm"
    "LIBXML2_LIBS=-lxml2 -llzma"
    "LIBXML2_CFLAGS=-I\"${CURRENT_INSTALLED_DIR}/include\""
    "GEOS_LDFLAGS=-lgeos_c -lgeos -lstdc++ -lm"
  )
  list(APPEND OPTIONS_DEBUG
    "CFLAGS=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
    "LIBS=-lpthread -ldl -lstdc++ -lm"
    "LIBXML2_LIBS=-lxml2 -llzmad"
    "LIBXML2_CFLAGS=-I\"${CURRENT_INSTALLED_DIR}/include\""
    "GEOS_LDFLAGS=-lgeos_cd -lgeosd -lstdc++ -lm"
  )

  vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS
      "GEOS_CFLAGS=-I\"${CURRENT_INSTALLED_DIR}/include\""
      "--enable-rttopo"
      "--enable-gcp"
      "--enable-geocallbacks"
      "--disable-examples"
      "--disable-minizip"
    OPTIONS_DEBUG
      ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
      ${OPTIONS_RELEASE}
  )

  vcpkg_install_make()
  vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)
else() # Other build system
  message(FATAL_ERROR "Unsupport build system.")
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)