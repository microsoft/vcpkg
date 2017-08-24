# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxWidgets/wxWidgets
    REF v3.1.0
    SHA512 740f3c977526395f32c2da4ea7f5f2ddc9b9a4cfd8d2cd129f011ede8e427621461c551c648b5d7a8f9ce78477e30426b836b310cff09c427ca8f9b9a9532074
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/use-installed-libs.patch"
)

find_program(NMAKE nmake REQUIRED)

set(NMAKE_OPTIONS "")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND NMAKE_OPTIONS TARGET_CPU=X64)
    set(LIB_SUB_PATH_PRE vc_x64)
else ()
    set(LIB_SUB_PATH_PRE vc)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND NMAKE_OPTIONS SHARED=1)
    set(LIB_SUB_PATH_TYP dll)
else()
    set(LIB_SUB_PATH_TYP lib)
endif()

if (VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND NMAKE_OPTIONS RUNTIME_LIBS=static)
endif()

set(LIB_SUB_PATH ${LIB_SUB_PATH_PRE}_${LIB_SUB_PATH_TYP}${TARGET_TRIPLET})

list(APPEND NMAKE_OPTIONS VCPKG_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include)

set(NMAKE_OPTIONS_REL
    ${NMAKE_OPTIONS}
    VCPKG_LIB_DIR=${CURRENT_INSTALLED_DIR}/lib
    BUILD=release
    CFG=${TARGET_TRIPLET}-rel
)

set(NMAKE_OPTIONS_DBG
    ${NMAKE_OPTIONS}
    VCPKG_LIB_DIR=${CURRENT_INSTALLED_DIR}/debug/lib
    CFG=${TARGET_TRIPLET}-dbg
)

file(REMOVE_RECURSE ${SOURCE_PATH}/lib/${LIB_SUB_PATH})

################
# Release build
################
message(STATUS "Building ${TARGET_TRIPLET}-rel")
set(ENV{_LINK_} ${CURRENT_INSTALLED_DIR}/lib/expat.lib)
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc ${NMAKE_OPTIONS_REL}
    WORKING_DIRECTORY ${SOURCE_PATH}/build/msw
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")

################
# Debug build
################
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
set(ENV{_LINK_} ${CURRENT_INSTALLED_DIR}/debug/lib/expatd.lib)
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc ${NMAKE_OPTIONS_DBG}
    WORKING_DIRECTORY ${SOURCE_PATH}/build/msw
    LOGNAME nmake-build-${TARGET_TRIPLET}-debug
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

# Install headers and libraries
file(INSTALL ${SOURCE_PATH}/include
    DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-rel/mswu/wx/setup.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/wx)
file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-rel/mswu/wx/msw/rcdefs.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/wx/msw)
file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-rel/
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.lib" PATTERN "*.pdb")
file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-dbg/
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.lib" PATTERN "*.pdb")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/mswu ${CURRENT_PACKAGES_DIR}/debug/lib/mswud)
    
# Handle copyright
file(COPY ${SOURCE_PATH}/docs/licence.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxwidgets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/wxWidgets/licence.txt ${CURRENT_PACKAGES_DIR}/share/wxwidgets/copyright)
