option(BUILD_DEBUG_TOOLS "Build debug version of tools" OFF)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/spatialite-tools-sources/spatialite-tools-4.3.0.tar.gz"
    FILENAME "spatialite-tools-4.3.0.tar.gz"
    SHA512 e1de27c1c65ff2ff0b08583113517bea74edf33fff59ad6e9c77492ea3ae87d9c0f17d7670ee6602b32eea73ad3678bb5410ef2c6fac6e213bf2e341a907db88
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-makefiles.patch
)

find_program(NMAKE nmake)

set(LDIR "\"${CURRENT_INSTALLED_DIR}\"")

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CL_FLAGS_DBG "/MDd /Zi /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(CL_FLAGS_REL "/MD /Ox /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(GEOS_LIBS_REL "${LDIR}/lib/geos_c.lib")
    set(GEOS_LIBS_DBG "${LDIR}/debug/lib/geos_cd.lib")
    set(LIBXML2_LIBS_REL "${LDIR}/lib/libxml2.lib")
    set(LIBXML2_LIBS_DBG "${LDIR}/debug/lib/libxml2.lib")
    set(SPATIALITE_LIBS_REL "${LDIR}/lib/spatialite.lib")
    set(SPATIALITE_LIBS_DBG "${LDIR}/debug/lib/spatialite.lib")
    set(ICONV_LIBS_REL "${LDIR}/lib/libiconv.lib")
    set(ICONV_LIBS_DBG "${LDIR}/debug/lib/libiconv.lib")
    set(EXPAT_LIBS_REL "${LDIR}/lib/libexpat.lib")
    set(EXPAT_LIBS_DBG "${LDIR}/debug/lib/libexpatd.lib")  
else()
    set(CL_FLAGS_DBG "/MTd /Zi /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(CL_FLAGS_REL "/MT /Ox /DACCEPT_USE_OF_DEPRECATED_PROJ_API_H")
    set(GEOS_LIBS_REL "${LDIR}/lib/geos_c.lib ${LDIR}/lib/geos.lib")
    set(GEOS_LIBS_DBG "${LDIR}/debug/lib/geos_cd.lib ${LDIR}/debug/lib/geosd.lib")
    set(LIBXML2_LIBS_REL "${LDIR}/lib/libxml2.lib ${LDIR}/lib/lzma.lib ws2_32.lib")
    set(LIBXML2_LIBS_DBG "${LDIR}/debug/lib/libxml2.lib ${LDIR}/debug/lib/lzmad.lib ws2_32.lib")
    set(SPATIALITE_LIBS_REL "${LDIR}/lib/spatialite.lib ${LDIR}/lib/freexl.lib")
    set(SPATIALITE_LIBS_DBG "${LDIR}/debug/lib/spatialite.lib ${LDIR}/debug/lib/freexl.lib")
    set(ICONV_LIBS_REL "${LDIR}/lib/libiconv.lib ${LDIR}/lib/libcharset.lib")
    set(ICONV_LIBS_DBG "${LDIR}/debug/lib/libiconv.lib ${LDIR}/debug/lib/libcharset.lib ")
    set(EXPAT_LIBS_REL "${LDIR}/lib/libexpatMD.lib")
    set(EXPAT_LIBS_DBG "${LDIR}/debug/lib/libexpatdMD.lib") 
endif()

set(LIBS_ALL_DBG
    "${ICONV_LIBS_DBG} \
    ${LDIR}/debug/lib/sqlite3.lib \
    ${SPATIALITE_LIBS_DBG} \
    ${LIBXML2_LIBS_DBG} \
    ${GEOS_LIBS_DBG} \
    ${EXPAT_LIBS_DBG} \
    ${LDIR}/debug/lib/readosm.lib \
    ${LDIR}/debug/lib/zlibd.lib \
    ${LDIR}/debug/lib/proj_d.lib"
   )
set(LIBS_ALL_REL
    "${ICONV_LIBS_REL} \
    ${LDIR}/lib/sqlite3.lib \
    ${SPATIALITE_LIBS_REL} \
    ${LIBXML2_LIBS_REL} \
    ${GEOS_LIBS_REL} \
    ${EXPAT_LIBS_REL} \
    ${LDIR}/lib/readosm.lib \
    ${LDIR}/lib/zlib.lib \
    ${LDIR}/lib/proj.lib"
   )

if(BUILD_DEBUG_TOOLS)
	################
	# Debug build
	################
	message(STATUS "Building ${TARGET_TRIPLET}-dgb")

	file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
	vcpkg_execute_required_process(
		COMMAND ${NMAKE} -f makefile.vc clean install
		"INST_DIR=\"${INST_DIR_REL}\"" "INSTALLED_ROOT=${LDIR}" "CL_FLAGS=${CL_FLAGS_DBG}" "LIBS_ALL=${LIBS_ALL_DBG}"
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME nmake-build-${TARGET_TRIPLET}-debug
	)
	message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
	set(EXE_FOLDER ${CURRENT_PACKAGES_DIR}/bin/)
else()
	################
	# Release build
	################
	message(STATUS "Building ${TARGET_TRIPLET}-rel")

	file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
	vcpkg_execute_required_process(
		COMMAND ${NMAKE} -f makefile.vc clean install
		"INST_DIR=\"${INST_DIR_REL}\"" "INSTALLED_ROOT=${LDIR}" "CL_FLAGS=${CL_FLAGS_REL}" "LIBS_ALL=${LIBS_ALL_REL}"
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME nmake-build-${TARGET_TRIPLET}-release
	)
	message(STATUS "Building ${TARGET_TRIPLET}-rel done")
	set(EXE_FOLDER ${CURRENT_PACKAGES_DIR}/bin/)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(GLOB EXES "${EXE_FOLDER}/*.exe")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(REMOVE ${EXES})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)

if(NOT BUILD_DEBUG_TOOLS AND VCPKG_CRT_LINKAGE STREQUAL dynamic)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

message(STATUS "Packaging ${TARGET_TRIPLET} done")

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
