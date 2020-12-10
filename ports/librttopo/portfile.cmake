# NOTE: update the version and checksum for new LIBRTTOPO release
set(LIBRTTOPO_VERSION_STR "1.1.0-2")
set(LIBRTTOPO_PACKAGE_SUM "cc2f646dd9ac3099c77e621984cdd2baa676ed1d8e6aaa9642afe2855e6fdef585603cc052ca09084204a1325e38bb626133072fbb5080e8adc369cc4854c40e")

vcpkg_download_distfile(ARCHIVE
    URLS "https://salsa.debian.org/debian-gis-team/librttopo/-/archive/debian/${LIBRTTOPO_VERSION_STR}/librttopo-debian-${LIBRTTOPO_VERSION_STR}.tar.gz"
    FILENAME "librttopo${LIBRTTOPO_VERSION_STR}.zip"
    SHA512 ${LIBRTTOPO_PACKAGE_SUM}
)

if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
      fix-makefiles.patch
  )

  # def symbols are modified from debian/librttopo1.symbols file
  file(COPY ${CMAKE_CURRENT_LIST_DIR}/librttopo.def DESTINATION ${SOURCE_PATH})
  set(SRID_MAX 999999)
  set(SRID_USR_MAX 998999)
  configure_file(${CMAKE_CURRENT_LIST_DIR}/rttopo_config.h.in ${SOURCE_PATH}/src/rttopo_config.h @ONLY)
  configure_file(${SOURCE_PATH}/headers/librttopo_geom.h.in ${SOURCE_PATH}/headers/librttopo_geom.h @ONLY)

  if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CL_FLAGS_DBG "/MDd /Zi /DDLL_EXPORT -I\"${CURRENT_INSTALLED_DIR}/include\"")
    set(CL_FLAGS_REL "/MD /Ox /DDLL_EXPORT -I\"${CURRENT_INSTALLED_DIR}/include\"")
    set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib")
    set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib")
  else()
    set(CL_FLAGS_DBG "/MTd /Zi -I\"${CURRENT_INSTALLED_DIR}/include\"")
    set(CL_FLAGS_REL "/MT /Ox -I\"${CURRENT_INSTALLED_DIR}/include\"")
    set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib ${CURRENT_INSTALLED_DIR}/lib/geos.lib")
    set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/geosd.lib")
  endif()

  string(REPLACE "/" "\\\\" INST_DIR ${CURRENT_PACKAGES_DIR})
  list(APPEND OPTIONS_RELEASE
    "LINK_FLAGS=" "INST_DIR=${INST_DIR}" "CL_FLAGS=${CL_FLAGS_REL}" "LIBS_ALL=${GEOS_LIBS_REL}"
  )
  list(APPEND OPTIONS_DEBUG
    "LINK_FLAGS=/debug" "INST_DIR=${INST_DIR}\\debug" "CL_FLAGS=${CL_FLAGS_DBG}" "LIBS_ALL=${GEOS_LIBS_DBG}"
  )

  vcpkg_install_nmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_RELEASE
      ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
      ${OPTIONS_DEBUG}
  )

  if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/librttopo.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/librttopo.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/librttopo_i.lib ${CURRENT_PACKAGES_DIR}/lib/librttopo.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/librttopo_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/librttopo.lib)
  else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/librttopo_i.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/librttopo_i.lib)
  endif()
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
      fix-geoconfig.patch
  )

  vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS
      "GEOS_MAJOR_VERSION=3"
      "GEOS_MINOR_VERSION=8"
    OPTIONS_DEBUG
      "GEOS_LDFLAGS=-lgeos_cd -lgeosd -lstdc++ -lm"
    OPTIONS_RELEASE
      "GEOS_LDFLAGS=-lgeos_c -lgeos -lstdc++ -lm"
  )

  vcpkg_install_make()
  vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)
else() # Other build system
  vcpkg_fail_port_install(ALWAYS)
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
