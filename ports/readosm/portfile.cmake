set(READOSM_VERSION_STR "1.1.0a")
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/readosm-sources/readosm-${READOSM_VERSION_STR}.tar.gz"
    FILENAME "readosm-${READOSM_VERSION_STR}.tar.gz"
    SHA512 ec8516cdd0b02027cef8674926653f8bc76e2082c778b02fb2ebcfa6d01e21757aaa4fd5d5104059e2f5ba97190183e60184f381bfd592a635805aa35cd7a682
)

if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_extract_source_archive_ex(
      OUT_SOURCE_PATH SOURCE_PATH
      ARCHIVE ${ARCHIVE}
      PATCHES
        fix-makefiles.patch
  )

  if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CL_FLAGS_DBG "/MDd /Zi")
    set(CL_FLAGS_REL "/MD /Ox")
    set(EXPAT_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libexpat.lib")
    set(EXPAT_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libexpatd.lib")
  else()
    set(CL_FLAGS_DBG "/MTd /Zi")
    set(CL_FLAGS_REL "/MT /Ox")
    set(EXPAT_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libexpatMD.lib")
    set(EXPAT_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libexpatdMD.lib")
  endif()

  if(VCPKG_TARGET_IS_UWP)
    set(UWP_LIBS windowsapp.lib)
    set(UWP_LINK_FLAGS /APPCONTAINER)
  endif()

  set(LIBS_ALL_DBG
    "${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib \
    ${UWP_LIBS} \
    ${EXPAT_LIBS_DBG}"
  )
  set(LIBS_ALL_REL
    "${CURRENT_INSTALLED_DIR}/lib/zlib.lib \
    ${UWP_LIBS} \
    ${EXPAT_LIBS_REL}"
  )

  string(REPLACE "/" "\\\\" INST_DIR ${CURRENT_PACKAGES_DIR})
  list(APPEND OPTIONS_RELEASE
    "LINK_FLAGS=${UWP_LINK_FLAGS}" "INST_DIR=${INST_DIR}" "CL_FLAGS=${CL_FLAGS_REL}" "LIBS_ALL=${LIBS_ALL_REL}"
  )
  list(APPEND OPTIONS_DEBUG
    "LINK_FLAGS=${UWP_LINK_FLAGS} /debug" "INST_DIR=${INST_DIR}\\debug" "CL_FLAGS=${CL_FLAGS_DBG}" "LIBS_ALL=${LIBS_ALL_DBG}"
   )

  vcpkg_install_nmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_RELEASE
      ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
      ${OPTIONS_DEBUG}
  )

  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/readosm_i.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/readosm_i.lib)
  else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/readosm.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/readosm.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/readosm_i.lib ${CURRENT_PACKAGES_DIR}/lib/readosm.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/readosm_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/readosm.lib)
  endif()
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
  )

  vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS
      "LIBS=-lpthread -ldl -lstdc++ -lm"
  )

  vcpkg_install_make()
  vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)