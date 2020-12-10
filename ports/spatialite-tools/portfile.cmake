set(SPATIALITE_TOOLS_VERSION_STR "5.0.0")
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/spatialite-tools-sources/spatialite-tools-${SPATIALITE_TOOLS_VERSION_STR}.tar.gz"
    FILENAME "spatialite-tools-${SPATIALITE_TOOLS_VERSION_STR}.tar.gz"
    SHA512 a1497824df2c45ffa1ba6b4ec53794c2c4779b6357885ee6f1243f2bff137c3e4dd93b0a802239ced73f66be22faf0081b83bf0ad4effb8a04052712625865d1
)

if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_extract_source_archive_ex(
      OUT_SOURCE_PATH SOURCE_PATH
      ARCHIVE ${ARCHIVE}
      PATCHES
        fix-makefiles.patch
  )

  if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CL_FLAGS_DBG "/MDd /Zi /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(CL_FLAGS_REL "/MD /Ox /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
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
    set(CL_FLAGS_DBG "/MTd /Zi /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(CL_FLAGS_REL "/MT /Ox /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
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

  set(LIBS_ALL_DBG
    "${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/readosm.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib \
    ${LIBXML2_LIBS_DBG} \
    ${GEOS_LIBS_DBG} \
    ${ICONV_LIBS_DBG} \
    ${SPATIALITE_LIBS_DBG} \
    ${EXPAT_LIBS_DBG} \
    ${CURRENT_INSTALLED_DIR}/debug/lib/proj_d.lib ole32.lib shell32.lib kernel32.lib windowsapp.lib"
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
    ${CURRENT_INSTALLED_DIR}/lib/proj.lib ole32.lib shell32.lib kernel32.lib windowsapp.lib"
  )

  string(REPLACE "/" "\\\\" INST_DIR ${CURRENT_PACKAGES_DIR})
  list(APPEND OPTIONS_RELEASE
    "LINK_FLAGS=/APPCONTAINER" "INST_DIR=${INST_DIR}" "CL_FLAGS=${CL_FLAGS_REL}" "LIBS_ALL=${LIBS_ALL_REL}"
  )
  list(APPEND OPTIONS_DEBUG
    "LINK_FLAGS=/APPCONTAINER /debug" "INST_DIR=${INST_DIR}\\debug" "CL_FLAGS=${CL_FLAGS_DBG}" "LIBS_ALL=${LIBS_ALL_DBG}"
   )

  vcpkg_install_nmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_RELEASE
      ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
      ${OPTIONS_DEBUG}
  )

  file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
  file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
  file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
  file(REMOVE ${EXES})

  file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/)
  file(GLOB DEBUG_EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
  file(COPY ${DEBUG_EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug)
  file(REMOVE ${DEBUG_EXES})

  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

  vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
  vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug)
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
      fix-linux-configure.patch
  )

  list(APPEND OPTIONS_RELEASE
    "CFLAGS=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
    "LIBS=-lpthread -ldl -lstdc++ -lm -lz"
    "LIBXML2_LIBS=-lxml2 -llzma"
    "LIBXML2_CFLAGS=-I\"${CURRENT_INSTALLED_DIR}/include\""
    "GEOS_LDFLAGS=-lgeos_c -lgeos -lstdc++ -lm"
  )
  list(APPEND OPTIONS_DEBUG
    "CFLAGS=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
    "LIBS=-lpthread -ldl -lstdc++ -lm -lz"
    "LIBXML2_LIBS=-lxml2 -llzmad"
    "LIBXML2_CFLAGS=-I\"${CURRENT_INSTALLED_DIR}/include\""
    "GEOS_LDFLAGS=-lgeos_cd -lgeosd -lstdc++ -lm"
  )

  vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS
      "--disable-minizip"
    OPTIONS_DEBUG
      ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
      ${OPTIONS_RELEASE}
  )

  vcpkg_install_make()
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
else() # Other build system
  message(FATAL_ERROR "Unsupport build system.")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)