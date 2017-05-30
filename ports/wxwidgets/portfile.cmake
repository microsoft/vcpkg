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
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/wxWidgets/wxWidgets/releases/download/v3.1.0/wxWidgets-3.1.0.7z"
    FILENAME "wxWidgets-3.1.0.7z"
    SHA512 309cd3c11052ab7ea77816ffcb70e280c0984fb7770c7e9999b4437d1ef9bb91c3f0521ad9d3592abd542bbed1fa74f6c83fce029504cf1ac4cf25e96c920b0f
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
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

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND NMAKE_OPTIONS SHARED=1)
    set(LIB_SUB_PATH_TYP dll)
else()
    list(APPEND NMAKE_OPTIONS RUNTIME_LIBS=static)
    set(LIB_SUB_PATH_TYP lib)
endif()

set(LIB_SUB_PATH ${LIB_SUB_PATH_PRE}_${LIB_SUB_PATH_TYP}${TARGET_TRIPLET})

list(APPEND NMAKE_OPTIONS VCPKG_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include)

set(NMAKE_OPTIONS_REL
    "${NMAKE_OPTIONS}"
    VCPKG_LIB_DIR=${CURRENT_INSTALLED_DIR}/lib
    BUILD=release
    CFG=${TARGET_TRIPLET}-rel
)

set(NMAKE_OPTIONS_DBG
    "${NMAKE_OPTIONS}"
    VCPKG_LIB_DIR=${CURRENT_INSTALLED_DIR}/debug/lib
    CFG=${TARGET_TRIPLET}-dbg
)

################
# Release build
################
message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc
    "${NMAKE_OPTIONS_REL}"
    WORKING_DIRECTORY ${SOURCE_PATH}/build/msw
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")

################
# Debug build
################
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc
    "${NMAKE_OPTIONS_DBG}"
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
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.lib")
file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-dbg/
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.lib" PATTERN "*.pdb")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/mswu ${CURRENT_PACKAGES_DIR}/debug/lib/mswud)
    
# Handle copyright
file(COPY ${SOURCE_PATH}/docs/licence.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxwidgets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/wxWidgets/licence.txt ${CURRENT_PACKAGES_DIR}/share/wxwidgets/copyright)
