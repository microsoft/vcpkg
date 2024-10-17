vcpkg_download_distfile(ARCHIVE
    URLS "https://dlcdn.apache.org/serf/serf-${VERSION}.tar.bz2"
    FILENAME "serf-${VERSION}.tar.bz2"
    SHA512 19165274d35c694935cda33f99ef92a7663a5d9c540fb7fd6792aa0efe39941b2fa87ff8b61afd060c6676baec634fd33dc2e9d34ecbee45ed99dfaed077802c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
      serf-fix-expat.patch
      serf-use-debug-libs.patch
)

# Note: custom architecture is not supported on Unix.
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(SCONS_ARCH "TARGET_ARCH=x86_64")
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(SCONS_ARCH "TARGET_ARCH=x86")
else()
  set(SCONS_ARCH "")
endif()

if(EXISTS "${CURRENT_INSTALLED_DIR}/bin/libapr-1.dll")
  set(APR_STATIC "no")
else()
  set(APR_STATIC "yes")
endif()

vcpkg_find_acquire_program(SCONS)

message(STATUS "Building ${TARGET_TRIPLET}-rel")

if(VCPKG_TARGET_IS_WINDOWS)
  SET(apr_opts
    "APR=${CURRENT_INSTALLED_DIR}"
    "APU=${CURRENT_INSTALLED_DIR}"
    "APR_STATIC=${APR_STATIC}"
  )
else()
  SET(apr_opts
    "APR=${CURRENT_INSTALLED_DIR}/tools/apr/bin/apr-1-config"
    "APU=${CURRENT_INSTALLED_DIR}/tools/apr-util/bin/apu-1-config"
  )
endif()

vcpkg_execute_build_process(
  COMMAND ${SCONS}
      "SOURCE_LAYOUT=no"
      "PREFIX=${CURRENT_PACKAGES_DIR}"
      "LIBDIR=${CURRENT_PACKAGES_DIR}/lib"
      "OPENSSL=${CURRENT_INSTALLED_DIR}"
      "ZLIB=${CURRENT_INSTALLED_DIR}"
      ${apr_opts}
      "${SCONS_ARCH}"
      "DEBUG=no"
      "install-lib" "install-inc" "install-pc"
  WORKING_DIRECTORY "${SOURCE_PATH}"
  LOGNAME "scons-rel"
)

# Fixup installed files.
if(VCPKG_TARGET_IS_WINDOWS)
  if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME
      "${CURRENT_PACKAGES_DIR}/lib/libserf-1.dll"
      "${CURRENT_PACKAGES_DIR}/bin/libserf-1.dll"
    )
    file(RENAME
      "${CURRENT_PACKAGES_DIR}/lib/libserf-1.pdb"
      "${CURRENT_PACKAGES_DIR}/bin/libserf-1.pdb"
    )
  else()
    file(REMOVE
      "${CURRENT_PACKAGES_DIR}/lib/libserf-1.dll"
      "${CURRENT_PACKAGES_DIR}/lib/libserf-1.pdb"
      "${CURRENT_PACKAGES_DIR}/lib/libserf-1.lib"
    )
  endif()
  file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libserf-1.exp")
endif()

if(NOT VCPKG_BUILD_TYPE)
  message(STATUS "Building ${TARGET_TRIPLET}-dbg")

  if(VCPKG_TARGET_IS_WINDOWS)
    SET(apr_opts
      "APR=${CURRENT_INSTALLED_DIR}/debug"
      "APU=${CURRENT_INSTALLED_DIR}/debug"
      "APR_STATIC=${APR_STATIC}"
    )
  else()
    SET(apr_opts
      "APR=${CURRENT_INSTALLED_DIR}/tools/apr/debug/bin/apr-1-config"
      "APU=${CURRENT_INSTALLED_DIR}/tools/apr-util/debug/bin/apu-1-config"
    )
  endif()

  vcpkg_execute_build_process(
      COMMAND ${SCONS}
          "SOURCE_LAYOUT=no"
          "PREFIX=${CURRENT_PACKAGES_DIR}/debug"
          "LIBDIR=${CURRENT_PACKAGES_DIR}/debug/lib"
          "OPENSSL=${CURRENT_INSTALLED_DIR}"
          "ZLIB=${CURRENT_INSTALLED_DIR}"
          ${apr_opts}
          "${SCONS_ARCH}"
          "DEBUG=yes"
          "install-lib" "install-pc"
      WORKING_DIRECTORY "${SOURCE_PATH}"
      LOGNAME "scons-dbg"
  )

  # Fixup installed files.
  if(VCPKG_TARGET_IS_WINDOWS)
    if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic")
      file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
      file(RENAME
        "${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.dll"
        "${CURRENT_PACKAGES_DIR}/debug/bin/libserf-1.dll"
      )
      file(RENAME
        "${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.pdb"
        "${CURRENT_PACKAGES_DIR}/debug/bin/libserf-1.pdb"
      )
    else()
      file(REMOVE
        "${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.dll"
        "${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.pdb"
        "${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.lib"
      )
    endif()
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libserf-1.exp")
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()
