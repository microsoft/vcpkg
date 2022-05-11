vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FastCGI-Archives/fcgi2
    REF fc8c6547ae38faf9926205a23075c47fbd4370c8
    SHA512   7f27b1060fbeaf0de9b8a43aa4ff954a004c49e99f7d6ea11119a438fcffe575fb469ba06262e71ac8132f92e74189e2097fd049595a6a61d4d5a5bac2733f7a
    HEAD_REF master
)

if (VCPKG_TARGET_IS_WINDOWS)
  # Check build system first
  find_program(NMAKE nmake REQUIRED)

  list(APPEND NMAKE_OPTIONS_REL
      CFG=release
  )

  list(APPEND NMAKE_OPTIONS_DBG
      CFG=debug
  )

  file(RENAME "${SOURCE_PATH}/include/fcgi_config_x86.h" "${SOURCE_PATH}/include/fcgi_config.h")
  vcpkg_build_nmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH libfcgi
    PROJECT_NAME libfcgi.mak
    OPTIONS_RELEASE
        "${NMAKE_OPTIONS_REL}"
    OPTIONS_DEBUG
        "${NMAKE_OPTIONS_DBG}"
  )

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME ${PORT})
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libfcgi/Release/libfcgi.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if (NOT VCPKG_CRT_LINKAGE STREQUAL static)
      file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libfcgi/Release/libfcgi.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    endif()
  endif()
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libfcgi/Debug/libfcgi.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    if (NOT VCPKG_CRT_LINKAGE STREQUAL static)
      file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libfcgi/Debug/libfcgi.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
  endif()
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  # Check build system first
  if(VCPKG_TARGET_IS_OSX)
      message("${PORT} currently requires the following library from the system package manager:\n    gettext\n    automake\n    libtool\n\nIt can be installed with brew install gettext automake libtool")
  else()
      message("${PORT} currently requires the following library from the system package manager:\n    gettext\n    automake\n    libtool\n    libtool-bin\n\nIt can be installed with apt-get install gettext automake libtool libtool-bin")
  endif()

  vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        COPY_SOURCE
    )

  vcpkg_install_make()

  # switch ${PORT} into /${PORT}
  file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include2")
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
  file(RENAME "${CURRENT_PACKAGES_DIR}/include2" "${CURRENT_PACKAGES_DIR}/include/${PORT}")

  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
  vcpkg_fixup_pkgconfig()
else() # Other build system
  message(FATAL_ERROR "fastcgi only supports Windows, Linux, and MacOS.")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.TERMS" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
