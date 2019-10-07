include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/epsilon-project/epsilon/0.9.2/epsilon-0.9.2.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fepsilon-project%2Ffiles%2Fepsilon%2F0.9.2%2Fepsilon-0.9.2.tar.gz%2Fdownload%3Fuse_mirror%3Dayera"
    FILENAME "epsilon-0.9.2.tar.gz"
    SHA512 95f427c68a4a4eb784f7d484d87fc573133983510f6b030663f88955e2446490a07b1343ae4668251b466f67cf9a79bd834b933c57c5ed12327f32174f20ac0f)

# Extract source into archictecture specific directory, because GDALs' nmake based build currently does not
# support out of source builds.
set(SOURCE_PATH_DEBUG   ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-debug/epsilon-0.9.2)
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-release/epsilon-0.9.2)
file(REMOVE_RECURSE ${SOURCE_PATH_DEBUG} ${SOURCE_PATH_RELEASE}) # to be sure that the patches can be properly applied, we always clean the buildtrees folder
foreach(BUILD_TYPE debug release)
    vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE})
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE}/epsilon-0.9.2
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/0001-VS2015-provides-snprintf.patch
            ${CMAKE_CURRENT_LIST_DIR}/0002-Add-CFLAGS-for-CRT-selection-and-warning-supression.patch
    )
endforeach()

find_program(NMAKE nmake REQUIRED)
if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(CL_FLAGS_REL "/MT /Ox /fp:precise")
    set(CL_FLAGS_DBG "/MTd /Zi")
    set(TARGET_LIB epsilon.lib)
else()
    set(CL_FLAGS_REL "/MD /Ox /fp:precise")
    set(CL_FLAGS_DBG "/MDd /Zi")
    set(TARGET_LIB epsilon_i.lib)
endif()

################
# Release build
################
message(STATUS "Building ${TARGET_TRIPLET}-rel")
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc
        "INSTDIR=\"${INST_DIR_REL}\""
        MSVC_VER=1900
        CRT_FLAGS=${CL_FLAGS_REL}
        INSTALLED_ROOT=${CURRENT_INSTALLED_DIR}
        ${TARGET_LIB}
    WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")

################
# Debug build
################
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" INST_DIR_DBG)
vcpkg_execute_required_process(
    COMMAND ${NMAKE} /G -f makefile.vc
        "INSTDIR=\"${INST_DIR_DBG}\""
        MSVC_VER=1900
        CRT_FLAGS=${CL_FLAGS_DBG}
        DEBUG=1
        INSTALLED_ROOT=${CURRENT_INSTALLED_DIR}
        ${TARGET_LIB}
    WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
    LOGNAME nmake-build-${TARGET_TRIPLET}-debug
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

message(STATUS "Packaging ${TARGET_TRIPLET}")
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/epsilon/filters)
if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${SOURCE_PATH_RELEASE}/epsilon.dll
         DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
    file(INSTALL ${SOURCE_PATH_DEBUG}/epsilon.dll
         DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
    file(INSTALL ${SOURCE_PATH_RELEASE}/epsilon_i.lib
         DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(INSTALL ${SOURCE_PATH_DEBUG}/epsilon_i.lib
         DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
else()
    file(INSTALL ${SOURCE_PATH_RELEASE}/epsilon.lib
         DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(INSTALL ${SOURCE_PATH_DEBUG}/epsilon.lib
         DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
endif()
file(COPY ${SOURCE_PATH_RELEASE}/lib/epsilon.h
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
file(GLOB FILTERS ${SOURCE_PATH_RELEASE}/filters/*.filter)
file(INSTALL ${FILTERS}
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/epsilon/filters/)
vcpkg_copy_pdbs()
file(INSTALL ${SOURCE_PATH_RELEASE}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/epsilon/ RENAME copyright)
message(STATUS "Packaging ${TARGET_TRIPLET} done")
