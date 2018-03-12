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

include(vcpkg_common_functions)
set(LAME_VESION 3.100)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lame-${LAME_VESION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/lame/files/lame/${LAME_VESION}/lame-${LAME_VESION}.tar.gz"
    FILENAME "lame-${LAME_VESION}.tar.gz"
    SHA512 0844b9eadb4aacf8000444621451277de365041cc1d97b7f7a589da0b7a23899310afd4e4d81114b9912aa97832621d20588034715573d417b2923948c08634b
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/enable-debug.patch
)

find_program(NMAKE nmake)

################
# Debug build
################

message(STATUS "Building ${TARGET_TRIPLET}-dbg")

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.MSVC config.h rebuild CPU=P3 asm=NO BUILD_TYPE=DEBUG
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME nmake-build-${TARGET_TRIPLET}-dbg
)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    file(COPY 
        ${SOURCE_PATH}/output/lame_enc.dll
        ${SOURCE_PATH}/output/lame_enc.pdb
        ${SOURCE_PATH}/output/libmp3lame.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY 
        ${SOURCE_PATH}/output/lame_enc.lib
        ${SOURCE_PATH}/output/libmp3lame.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
else()
    file(COPY 
        ${SOURCE_PATH}/output/libmp3lame-static.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

################
# Release build
################

message(STATUS "Building ${TARGET_TRIPLET}-rel")

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.MSVC config.h rebuild CPU=P3 asm=NO BUILD_TYPE=RELEASE
        "CL_FLAGS=${CL_FLAGS_REL}"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME nmake-build-${TARGET_TRIPLET}-rel
)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    file(COPY 
        ${SOURCE_PATH}/output/lame_enc.dll
        ${SOURCE_PATH}/output/libmp3lame.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY 
        ${SOURCE_PATH}/output/lame_enc.lib
        ${SOURCE_PATH}/output/libmp3lame.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
else()
    file(COPY 
        ${SOURCE_PATH}/output/libmp3lame-static.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()
file(COPY 
    ${SOURCE_PATH}/include/lame.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY 
    ${SOURCE_PATH}/output/lame.exe
    ${SOURCE_PATH}/output/mp3rtp.exe
    DESTINATION ${CURRENT_INSTALLED_DIR}/tools/lame)

message(STATUS "Building ${TARGET_TRIPLET}-rel done")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/lame RENAME copyright)
