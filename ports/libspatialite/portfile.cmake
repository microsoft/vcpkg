include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libspatialite-4.3.0a)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-4.3.0a.tar.gz"
    FILENAME "libspatialite-4.3.0a.tar.gz"
    SHA512 adfd63e8dde0f370b07e4e7bb557647d2bfb5549205b60bdcaaca69ff81298a3d885e7c1ca515ef56dd0aca152ae940df8b5dbcb65bb61ae0a9337499895c3c0
)
vcpkg_extract_source_archive(${ARCHIVE})

find_program(NMAKE nmake)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-makefiles.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-sources.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-latin-literals.patch
)

# fix most of the problems when spacebar is in the path
set(CURRENT_INSTALLED_DIR "\"${CURRENT_INSTALLED_DIR}\"")

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CL_FLAGS_DBG "/MDd /Zi")
    set(CL_FLAGS_REL "/MD /Ox")
    set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib")
    set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib")
    set(LIBXML2_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib")
    set(LIBXML2_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib")
else()
    set(CL_FLAGS_DBG "/MTd /Zi")
    set(CL_FLAGS_REL "/MT /Ox")
    set(GEOS_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libgeos_c.lib ${CURRENT_INSTALLED_DIR}/lib/libgeos.lib")
    set(GEOS_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libgeos_cd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/libgeosd.lib")
    set(LIBXML2_LIBS_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib ${CURRENT_INSTALLED_DIR}/lib/lzma.lib ws2_32.lib")
    set(LIBXML2_LIBS_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib ${CURRENT_INSTALLED_DIR}/debug/lib/lzmad.lib ws2_32.lib")
endif()

set(LIBS_ALL_DBG
    "${CURRENT_INSTALLED_DIR}/debug/lib/libiconv.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/libcharset.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/freexl.lib \
    ${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib \
    ${LIBXML2_LIBS_DBG} \
    ${GEOS_LIBS_DBG} \
    ${CURRENT_INSTALLED_DIR}/debug/lib/projd.lib"
   )
set(LIBS_ALL_REL
    "${CURRENT_INSTALLED_DIR}/lib/libiconv.lib \
    ${CURRENT_INSTALLED_DIR}/lib/libcharset.lib \
    ${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib \
    ${CURRENT_INSTALLED_DIR}/lib/freexl.lib \
    ${CURRENT_INSTALLED_DIR}/lib/zlib.lib \
    ${LIBXML2_LIBS_REL} \
    ${GEOS_LIBS_REL} \
    ${CURRENT_INSTALLED_DIR}/lib/proj.lib"
   )

################
# Debug build
################
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" INST_DIR_DBG)

    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f makefile.vc clean install
        "INST_DIR=\"${INST_DIR_DBG}\"" INSTALLED_ROOT=${CURRENT_INSTALLED_DIR} "LINK_FLAGS=/debug" "CL_FLAGS=${CL_FLAGS_DBG}" "LIBS_ALL=${LIBS_ALL_DBG}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME nmake-build-${TARGET_TRIPLET}-debug
    )
    message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
    vcpkg_copy_pdbs()
endif()

################
# Release build
################
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    message(STATUS "Building ${TARGET_TRIPLET}-rel")

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f makefile.vc clean install
        "INST_DIR=\"${INST_DIR_REL}\"" INSTALLED_ROOT=${CURRENT_INSTALLED_DIR} "LINK_FLAGS=" "CL_FLAGS=${CL_FLAGS_REL}" "LIBS_ALL=${LIBS_ALL_REL}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME nmake-build-${TARGET_TRIPLET}-release
    )
    message(STATUS "Building ${TARGET_TRIPLET}-rel done")
endif()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libspatialite RENAME copyright)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib)
else()
  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/spatialite.lib)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib)
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/spatialite_i.lib ${CURRENT_PACKAGES_DIR}/lib/spatialite.lib)
  endif()
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/spatialite.lib)
  endif()
endif()

message(STATUS "Packaging ${TARGET_TRIPLET} done")
