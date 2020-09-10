include(${CMAKE_CURRENT_LIST_DIR}/dependency.cmake)

vcpkg_fail_port_install(ON_ARCH "arm")

# NOTE: update the version and checksum for new GDAL release
set(GDAL_VERSION_STR "3.1.3")
set(GDAL_VERSION_PKG "313")
set(GDAL_VERSION_LIB "204")
set(GDAL_PACKAGE_SUM "a6dad37813eecb5e0c888ec940cf7f83c5096e69e4f33a3e5a5557542e7f656b9726e470e1b5d3d035de53df065510931a436a8c889f1366abd630c1cf5dfb49")

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/gdal/${GDAL_VERSION_STR}/gdal${GDAL_VERSION_PKG}.zip"
    FILENAME "gdal${GDAL_VERSION_PKG}.zip"
    SHA512 ${GDAL_PACKAGE_SUM}
)

set(GDAL_PATCHES 0001-Fix-debug-crt-flags.patch 0002-Fix-build.patch)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND GDAL_PATCHES 0003-Fix-static-build.patch)
endif()
list(APPEND GDAL_PATCHES 0004-Fix-std-fabs.patch)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES ${GDAL_PATCHES}
)

if (VCPKG_TARGET_IS_WINDOWS)
  set(NATIVE_DATA_DIR "${CURRENT_PACKAGES_DIR}/share/gdal")
  set(NATIVE_HTML_DIR "${CURRENT_PACKAGES_DIR}/share/gdal/html")

  find_dependency()

  if("mysql-libmysql" IN_LIST FEATURES OR "mysql-libmariadb" IN_LIST FEATURES)
      list(APPEND NMAKE_OPTIONS MYSQL_INC_DIR=${MYSQL_INCLUDE_DIR})
      list(APPEND NMAKE_OPTIONS_REL MYSQL_LIB=${MYSQL_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG MYSQL_LIB=${MYSQL_LIBRARY_DBG})
  endif()

  list(APPEND NMAKE_OPTIONS
      DATADIR=${NATIVE_DATA_DIR}
      HTMLDIR=${NATIVE_HTML_DIR}
      GEOS_DIR=${GEOS_INCLUDE_DIR}
      "GEOS_CFLAGS=-I${GEOS_INCLUDE_DIR} -DHAVE_GEOS"
      PROJ_INCLUDE=-I${PROJ_INCLUDE_DIR}
      EXPAT_DIR=${EXPAT_INCLUDE_DIR}
      EXPAT_INCLUDE=-I${EXPAT_INCLUDE_DIR}
      CURL_INC=-I${CURL_INCLUDE_DIR}
      "SQLITE_INC=-I${SQLITE_INCLUDE_DIR} ${HAVE_SPATIALITE}"
      PG_INC_DIR=${PGSQL_INCLUDE_DIR}
      OPENJPEG_ENABLED=YES
      OPENJPEG_CFLAGS=-I${OPENJPEG_INCLUDE_DIR}
      OPENJPEG_VERSION=20100
      WEBP_ENABLED=YES
      WEBP_CFLAGS=-I${WEBP_INCLUDE_DIR}
      LIBXML2_INC=-I${XML2_INCLUDE_DIR}
      PNG_EXTERNAL_LIB=1
      PNGDIR=${PNG_INCLUDE_DIR}
      ZLIB_INC=-I${ZLIB_INCLUDE_DIR}
      ZLIB_EXTERNAL_LIB=1
      ACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1
      MSVC_VER=1900
  )

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      list(APPEND NMAKE_OPTIONS WIN64=YES)
  endif()

  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
      list(APPEND NMAKE_OPTIONS CURL_CFLAGS=-DCURL_STATICLIB)
      list(APPEND NMAKE_OPTIONS DLLBUILD=0)
      list(APPEND NMAKE_OPTIONS "PROJ_FLAGS=-DPROJ_STATIC -DPROJ_VERSION=5")
  else()
      # Enables PDBs for release and debug builds
      list(APPEND NMAKE_OPTIONS WITH_PDB=1)
      list(APPEND NMAKE_OPTIONS DLLBUILD=1)
  endif()

  if (VCPKG_CRT_LINKAGE STREQUAL static)
      set(LINKAGE_FLAGS "/MT")
  else()
      set(LINKAGE_FLAGS "/MD")
  endif()

  list(APPEND NMAKE_OPTIONS_REL
      ${NMAKE_OPTIONS}
      GDAL_HOME=${CURRENT_PACKAGES_DIR}
      CXX_CRT_FLAGS=${LINKAGE_FLAGS}
      PROJ_LIBRARY=${PROJ_LIBRARY_REL}
      PNG_LIB=${PNG_LIBRARY_REL}
      "GEOS_LIB=${GEOS_LIBRARY_REL}"
      EXPAT_LIB=${EXPAT_LIBRARY_REL}
      "CURL_LIB=${CURL_LIBRARY_REL} wsock32.lib wldap32.lib winmm.lib"
      "SQLITE_LIB=${SQLITE_LIBRARY_REL} ${SPATIALITE_LIBRARY_REL}"
      OPENJPEG_LIB=${OPENJPEG_LIBRARY_REL}
      WEBP_LIBS=${WEBP_LIBRARY_REL}
      "LIBXML2_LIB=${XML2_LIBRARY_REL} ${ICONV_LIBRARY_REL} ${LZMA_LIBRARY_REL}"
      ZLIB_LIB=${ZLIB_LIBRARY_REL}
      "PG_LIB=${PGSQL_LIBRARY_REL} Secur32.lib Shell32.lib Advapi32.lib Crypt32.lib Gdi32.lib ${OPENSSL_LIBRARY_REL}"
  )

  list(APPEND NMAKE_OPTIONS_DBG
      ${NMAKE_OPTIONS}
      GDAL_HOME=${CURRENT_PACKAGES_DIR}/debug
      CXX_CRT_FLAGS="${LINKAGE_FLAGS}d"
      PROJ_LIBRARY=${PROJ_LIBRARY_DBG}
      PNG_LIB=${PNG_LIBRARY_DBG}
      "GEOS_LIB=${GEOS_LIBRARY_DBG}"
      EXPAT_LIB=${EXPAT_LIBRARY_DBG}
      "CURL_LIB=${CURL_LIBRARY_DBG} wsock32.lib wldap32.lib winmm.lib"
      "SQLITE_LIB=${SQLITE_LIBRARY_DBG} ${SPATIALITE_LIBRARY_DBG}"
      OPENJPEG_LIB=${OPENJPEG_LIBRARY_DBG}
      WEBP_LIBS=${WEBP_LIBRARY_DBG}
      "LIBXML2_LIB=${XML2_LIBRARY_DBG} ${ICONV_LIBRARY_DBG} ${LZMA_LIBRARY_DBG}"
      ZLIB_LIB=${ZLIB_LIBRARY_DBG}
      "PG_LIB=${PGSQL_LIBRARY_DBG} Secur32.lib Shell32.lib Advapi32.lib Crypt32.lib Gdi32.lib ${OPENSSL_LIBRARY_DBG}"
      DEBUG=1
  )

  # Begin build process
  vcpkg_install_nmake(
    SOURCE_PATH ${SOURCE_PATH}
    INSTALL_COMMAND install devinstall
    OPTIONS_RELEASE
        "${NMAKE_OPTIONS_REL}"
    OPTIONS_DEBUG
        "${NMAKE_OPTIONS_DBG}"
  )

  if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/gdal/html)
  endif()

  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
  endif()
  #
  #  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  #    file(COPY gdal.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  #  endif()
  #
  #  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  #    file(COPY gdal.lib   DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  #    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gdal.lib ${CURRENT_PACKAGES_DIR}/debug/lib/gdald.lib)
  #  endif()
  #
  #else()
  #
  #  set(GDAL_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/gdal)
  #  file(MAKE_DIRECTORY ${GDAL_TOOL_PATH})
  #
  #  file(GLOB GDAL_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
  #  file(COPY ${GDAL_TOOLS} DESTINATION ${GDAL_TOOL_PATH})
  #  file(REMOVE_RECURSE ${GDAL_TOOLS})
  #
  #  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/gdal.lib)
  #
  #  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  #    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gdal_i.lib ${CURRENT_PACKAGES_DIR}/lib/gdal.lib)
  #  endif()
  #  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  #    file(COPY gdal${GDAL_VERSION_LIB}.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
  #    file(COPY gdal_i.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  #    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gdal_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/gdald.lib)
  #  endif()
  #endif()

  # Copy over PDBs
  vcpkg_copy_pdbs()
  
  if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/gdal204.pdb)
  endif()

elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(BUILD_DYNAMIC yes)
        set(BUILD_STATIC no)
    else()
        set(BUILD_DYNAMIC no)
        set(BUILD_STATIC yes)
    endif()
    
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        COPY_SOURCE
        OPTIONS
            --enable-shared=${BUILD_DYNAMIC}
            --enable-static=${BUILD_STATIC}
        OPTIONS_DEBUG
            --enable-debug
            #--with-boost-lib-path=${CURRENT_INSTALLED_DIR}/debug/lib
        OPTIONS_RELEASE
            #--with-boost-lib-path=${CURRENT_INSTALLED_DIR}/lib
    )

  #if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  #  ################
  #  # Release build
  #  ################
  #  message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
  #  set(OUT_PATH_RELEASE ${SOURCE_PATH}/../../make-build-${TARGET_TRIPLET}-release)
  #  file(MAKE_DIRECTORY ${OUT_PATH_RELEASE})
  #  vcpkg_execute_required_process(
  #    COMMAND "${SOURCE_PATH}/configure" --prefix=${OUT_PATH_RELEASE}
  #    WORKING_DIRECTORY ${SOURCE_PATH}
  #    LOGNAME config-${TARGET_TRIPLET}-rel
  #  )
  #
  #  message(STATUS "Building ${TARGET_TRIPLET}-rel")
  #  vcpkg_execute_build_process(
  #    COMMAND make -j ${VCPKG_CONCURRENCY}
  #    NO_PARALLEL_COMMAND make
  #    WORKING_DIRECTORY ${SOURCE_PATH}
  #    LOGNAME make-build-${TARGET_TRIPLET}-release
  #  )
  #
  #  message(STATUS "Installing ${TARGET_TRIPLET}-rel")
  #  vcpkg_execute_required_process(
  #    COMMAND make install
  #    WORKING_DIRECTORY ${SOURCE_PATH}
  #    LOGNAME make-install-${TARGET_TRIPLET}-release
  #  )
  #
  #  file(REMOVE_RECURSE ${OUT_PATH_RELEASE}/lib/gdalplugins)
  #  file(COPY ${OUT_PATH_RELEASE}/lib/pkgconfig DESTINATION ${OUT_PATH_RELEASE}/share/gdal)
  #  file(REMOVE_RECURSE ${OUT_PATH_RELEASE}/lib/pkgconfig)
  #  file(COPY ${OUT_PATH_RELEASE}/lib DESTINATION ${CURRENT_PACKAGES_DIR})
  #  file(COPY ${OUT_PATH_RELEASE}/include DESTINATION ${CURRENT_PACKAGES_DIR})
  #  file(COPY ${OUT_PATH_RELEASE}/share DESTINATION ${CURRENT_PACKAGES_DIR})
  #  message(STATUS "Installing ${TARGET_TRIPLET}-rel done")
  #endif()
  #
  #if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  #  ################
  #  # Debug build
  #  ################
  #  message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
  #  set(OUT_PATH_DEBUG ${SOURCE_PATH}/../../make-build-${TARGET_TRIPLET}-debug)
  #  file(MAKE_DIRECTORY ${OUT_PATH_DEBUG})
  #  vcpkg_execute_required_process(
  #    COMMAND "${SOURCE_PATH}/configure" --prefix=${OUT_PATH_DEBUG}
  #    WORKING_DIRECTORY ${SOURCE_PATH}
  #    LOGNAME config-${TARGET_TRIPLET}-debug
  #  )
  #
  #  message(STATUS "Building ${TARGET_TRIPLET}-dbg")
  #  vcpkg_execute_build_process(
  #    COMMAND make -j ${VCPKG_CONCURRENCY}
  #    NO_PARALLEL_COMMAND make
  #    WORKING_DIRECTORY ${SOURCE_PATH}
  #    LOGNAME make-build-${TARGET_TRIPLET}-debug
  #  )
  #
  #  message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
  #  vcpkg_execute_required_process(
  #    COMMAND make -j install
  #    WORKING_DIRECTORY ${SOURCE_PATH}
  #    LOGNAME make-install-${TARGET_TRIPLET}-debug
  #  )
  #
  #  file(REMOVE_RECURSE ${OUT_PATH_DEBUG}/lib/gdalplugins)
  #  file(REMOVE_RECURSE ${OUT_PATH_DEBUG}/lib/pkgconfig)
  #  file(COPY ${OUT_PATH_DEBUG}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
  #  message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")
  #endif()
else() # Other build system
  message(FATAL_ERROR "Unsupport build system.")
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
