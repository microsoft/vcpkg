vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# NOTE: update the version and checksum for new LIBRTTOPO release
set(LIBRTTOPO_VERSION_STR "1.1.0-2")
set(LIBRTTOPO_PACKAGE_SUM "cc2f646dd9ac3099c77e621984cdd2baa676ed1d8e6aaa9642afe2855e6fdef585603cc052ca09084204a1325e38bb626133072fbb5080e8adc369cc4854c40e")

vcpkg_download_distfile(ARCHIVE
    URLS "https://salsa.debian.org/debian-gis-team/librttopo/-/archive/debian/${LIBRTTOPO_VERSION_STR}/librttopo-debian-${LIBRTTOPO_VERSION_STR}.tar.gz"
    FILENAME "librttopo${LIBRTTOPO_VERSION_STR}.zip"
    SHA512 ${LIBRTTOPO_PACKAGE_SUM}
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        fix-makefiles.patch
        fix-geoconfig.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
  set(SRID_MAX 999999)
  set(SRID_USR_MAX 998999)
  configure_file(${CMAKE_CURRENT_LIST_DIR}/rttopo_config.h.in ${SOURCE_PATH}/src/rttopo_config.h @ONLY)
  configure_file(${SOURCE_PATH}/headers/librttopo_geom.h.in ${SOURCE_PATH}/headers/librttopo_geom.h @ONLY)

  vcpkg_build_nmake(
      SOURCE_PATH ${SOURCE_PATH}
      TARGET librttopo.lib
  )

  file(GLOB LIBRTTOPO_INCLUDE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/headers/*.h)
  file(COPY ${LIBRTTOPO_INCLUDE} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

  file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/librttopo.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/librttopo.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  vcpkg_configure_make(
      SOURCE_PATH ${SOURCE_PATH}
      AUTOCONFIG
      OPTIONS
          "GEOS_MAJOR_VERSION=3"
          "GEOS_MINOR_VERSION=8"
      OPTIONS_DEBUG
          "GEOS_LDFLAGS=-lgeos_cd -lgeosd -lm"
      OPTIONS_RELEASE
          "GEOS_LDFLAGS=-lgeos_c -lgeos -lm"
  )

  vcpkg_install_make()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
