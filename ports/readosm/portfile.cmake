vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP")

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/readosm-sources/readosm-1.1.0.tar.gz"
    FILENAME "readosm-1.1.0.tar.gz"
    SHA512 d3581f564c4461c6a1a3d5fd7d18a262c884b2ac935530064bfaebd6c05d692fb92cc600fb40e87e03f7160ebf0eeeb05f51a0e257935d056b233fe28fc01a11
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-makefiles.patch
        fix-version-macro.patch
)

find_program(NMAKE nmake)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(LIBS_ALL_DBG "\"${CURRENT_INSTALLED_DIR}/debug/lib/libexpatd.lib\" \"${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib\"")
    set(LIBS_ALL_REL "\"${CURRENT_INSTALLED_DIR}/lib/libexpat.lib\" \"${CURRENT_INSTALLED_DIR}/lib/zlib.lib\"")
	set(CL_FLAGS_DBG "/MDd /Zi")
	set(CL_FLAGS_REL "/MD /Ox")
else()
    set(LIBS_ALL_DBG "\"${CURRENT_INSTALLED_DIR}/debug/lib/libexpatdMD.lib\" \"${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib\"")
    set(LIBS_ALL_REL "\"${CURRENT_INSTALLED_DIR}/lib/libexpatMD.lib\" \"${CURRENT_INSTALLED_DIR}/lib/zlib.lib\"")
	set(CL_FLAGS_DBG "/MTd /Zi")
	set(CL_FLAGS_REL "/MT /Ox")
endif()

################
# Debug build
################
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" INST_DIR_DBG)

    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f makefile.vc clean install
        INST_DIR="${INST_DIR_DBG}" INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}" "LINK_FLAGS=/debug" "CL_FLAGS=${CL_FLAGS_DBG}"
        "LIBS_ALL=${LIBS_ALL_DBG}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME nmake-build-${TARGET_TRIPLET}-debug
    )
    vcpkg_copy_pdbs()
    message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
endif()

################
# Release build
################
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    message(STATUS "Building ${TARGET_TRIPLET}-rel")

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f makefile.vc clean install
        INST_DIR="${INST_DIR_REL}" INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}" "LINK_FLAGS=" "CL_FLAGS=${CL_FLAGS_REL}"
        "LIBS_ALL=${LIBS_ALL_REL}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME nmake-build-${TARGET_TRIPLET}-release
    )
    message(STATUS "Building ${TARGET_TRIPLET}-rel done")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/readosm_i.lib)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/readosm_i.lib)
else()
  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/readosm.lib)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/readosm.lib)
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/readosm_i.lib ${CURRENT_PACKAGES_DIR}/lib/readosm.lib)
  endif()
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/readosm_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/readosm.lib)
  endif()
endif()

message(STATUS "Packaging ${TARGET_TRIPLET} done")

#Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)