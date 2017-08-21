# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

#message("VCPKG_TARGET_ARCHITECTURE" ${VCPKG_TARGET_ARCHITECTURE})
#if(NOT ${VCPKG_TARGET_ARCHITECTURE} STREQUAL "x86")
#    message(FATAL_ERROR "chmlib only supports x86")
#endif()

if(${VCPKG_CRT_LINKAGE} STREQUAL "dynamic")
    message(FATAL_ERROR "chmlib supports static linking only.")
endif()

if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "dynamic")
    message(FATAL_ERROR "chmlib supports static linking only.")
endif()

set(CHMLIB_VERSION chmlib-0.40)
set(CHMLIB_FILENAME ${CHMLIB_VERSION}.zip)
set(CHMLIB_URL http://www.jedrea.com/chmlib/${CHMLIB_FILENAME})
set(CHMLIB_SRC ${CURRENT_BUILDTREES_DIR}/src/${CHMLIB_VERSION}/src)
include(vcpkg_common_functions)

vcpkg_download_distfile(
    ARCHIVE
    URLS ${CHMLIB_URL}
    FILENAME ${CHMLIB_FILENAME}
    SHA512 ad3b0d49fcf99e724c0c38b9c842bae9508d0e4ad47122b0f489c113160f5344223d311abb79f25cbb0b662bb00e2925d338d60dd20a0c309bda2822cda4cd24
)   
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY "${VCPKG_ROOT_DIR}/ports/${PORT}/chm.vcxproj"
    DESTINATION ${CHMLIB_SRC})

vcpkg_build_msbuild(
    PROJECT_PATH ${CHMLIB_SRC}/chm.vcxproj
    RELEASE_CONFIGURATION Release
    DEBUG_CONFIGURATION Debug
    OPTIONS_DEBUG /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    OPTIONS_RELEASE /p:OutDirPath="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    OPTIONS /v:diagnostic /p:SkipInvalidConfigurations=true
)

file(INSTALL ${CHMLIB_SRC}/chm_lib.h  DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/chm.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/chm.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/chmlib-0.40/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/chmlib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/chmlib/COPYING ${CURRENT_PACKAGES_DIR}/share/chmlib/copyright)