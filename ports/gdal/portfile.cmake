if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR " ARM is currently not supported.")
endif()

include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/gdal/1.11.3/gdal1113.zip"
    FILENAME "gdal1113.zip"
    SHA512 42feb98a54019d3b6ac54f598f299a57e117db500c662d39faa9d5f5090f03c1b8d7680242e1abd8035738edc4fc3197ae118a0ce50733691a76a5cf377bcd46
)

# Extract source into archictecture specific directory, because GDALs' nmake based build currently does not
# support out of source builds.
set(SOURCE_PATH_DEBUG   ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-debug/gdal-1.11.3)
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-release/gdal-1.11.3)

foreach(BUILD_TYPE debug release)
    vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE})
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE}/gdal-1.11.3
        PATCHES 
        ${CMAKE_CURRENT_LIST_DIR}/0001-Add-support-for-MSVC1900-backported-from-GDAL2.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-Add-variable-CXX_CRT_FLAGS-to-allow-for-selection-of.patch
        ${CMAKE_CURRENT_LIST_DIR}/0003-Ensures-inclusion-of-PDB-in-release-dll-if-so-reques.patch
    )
endforeach()

find_program(NMAKE nmake REQUIRED)

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/share/gdal" NATIVE_DATA_DIR)
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/share/gdal/html" NATIVE_HTML_DIR)

# Setup proj4 libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PROJ_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/proj.lib" PROJ_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/projd.lib" PROJ_LIBRARY_DBG)

# Setup libpng libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PNG_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libpng16.lib" PNG_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.lib" PNG_LIBRARY_DBG)

# Setup geos libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" GEOS_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib" GEOS_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/geos_c.lib" GEOS_LIBRARY_DBG)

set(NMAKE_OPTIONS
    GDAL_HOME=${NATIVE_PACKAGES_DIR}
    DATADIR=${NATIVE_DATA_DIR}
    HTMLDIR=${NATIVE_HTML_DIR}
    GEOS_DIR=${GEOS_INCLUDE_DIR}
    "GEOS_CFLAGS=-I${GEOS_INCLUDE_DIR} -DHAVE_GEOS"
    PROJ_INCLUDE=-I${PROJ_INCLUDE_DIR}
    PNG_EXTERNAL_LIB=1
    PNGDIR=${PNG_INCLUDE_DIR}
    MSVC_VER=1900
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND NMAKE_OPTIONS WIN64=YES)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND NMAKE_OPTIONS PROJ_FLAGS=-DPROJ_STATIC)
else()    
    # Enables PDBs for release and debug builds
    list(APPEND NMAKE_OPTIONS WITH_PDB=1)
endif()

if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(LINKAGE_FLAGS "/MT")
else()
    set(LINKAGE_FLAGS "/MD")
endif()

set(NMAKE_OPTIONS_REL
    "${NMAKE_OPTIONS}"
    CXX_CRT_FLAGS=${LINKAGE_FLAGS}
    PROJ_LIBRARY=${PROJ_LIBRARY_REL}
    PNG_LIB=${PNG_LIBRARY_REL}
    GEOS_LIB=${GEOS_LIBRARY_REL}
)

set(NMAKE_OPTIONS_DBG
    "${NMAKE_OPTIONS}"
    CXX_CRT_FLAGS="${LINKAGE_FLAGS}d"
    PROJ_LIBRARY=${PROJ_LIBRARY_DBG}
    PNG_LIB=${PNG_LIBRARY_DBG}
    GEOS_LIB=${GEOS_LIBRARY_DBG}
    DEBUG=1
)
################
# Release build
################
message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc 
    "${NMAKE_OPTIONS_REL}"
    WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")

################
# Debug build
################
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
  COMMAND ${NMAKE} /G -f makefile.vc 
  "${NMAKE_OPTIONS_DBG}"
  WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
  LOGNAME nmake-build-${TARGET_TRIPLET}-debug
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

message(STATUS "Packaging ${TARGET_TRIPLET}")
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/gdal/html)

vcpkg_execute_required_process(
  COMMAND ${NMAKE} -f makefile.vc 
  "${NMAKE_OPTIONS_REL}"
  "install"
  "devinstall"
  WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
  LOGNAME nmake-install-${TARGET_TRIPLET}
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/gdal_i.lib)
  file(COPY ${SOURCE_PATH_DEBUG}/gdal.lib   DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(COPY ${SOURCE_PATH_RELEASE}/gdal.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gdal.lib ${CURRENT_PACKAGES_DIR}/debug/lib/gdald.lib)
else()
  file(GLOB EXE_FILES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
  file(REMOVE ${EXE_FILES} ${CURRENT_PACKAGES_DIR}/lib/gdal.lib)
  file(COPY ${SOURCE_PATH_DEBUG}/gdal111.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
  file(COPY ${SOURCE_PATH_DEBUG}/gdal_i.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gdal_i.lib ${CURRENT_PACKAGES_DIR}/lib/gdal.lib)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gdal_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/gdald.lib)
endif()

# Copy over PDBs
vcpkg_copy_pdbs()

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gdal/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/gdal/copyright)

message(STATUS "Packaging ${TARGET_TRIPLET} done")
