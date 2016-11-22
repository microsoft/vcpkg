# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libxslt-1.1.29)
vcpkg_download_distfile(ARCHIVE
    URLS "ftp://xmlsoft.org/libxslt/libxslt-1.1.29.tar.gz"
    FILENAME "libxslt-1.1.29.tar.gz"
    SHA512 a1ce555a74a9dabe65e8f64bb66e27e77760fd76940d88f2d59f58dd63ca73c8ae59f3fcbd8e76c8f92ff992fb0c09328528c20ea38ccac83e63252106bf5f31
)
vcpkg_extract_source_archive(${ARCHIVE})

find_program(NMAKE nmake)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}/
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Fix-makefile.patch
)

set(SCRIPTS_DIR ${SOURCE_PATH}/win32)

set(CONFIGURE_COMMAND_TEMPLATE cscript configure.js
    cruntime=@CRUNTIME@
    debug=@DEBUGMODE@
    prefix=@INSTALL_DIR@
    include=@INCLUDE_DIR@
    lib=@LIB_DIR@
    bindir=$(PREFIX)\\tools\\
    sodir=$(PREFIX)\\bin\\
)

# Create some directories ourselves, because the makefile doesn't
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)

#
# Release
#

message(STATUS "Configuring ${TARGET_TRIPLET}-rel")

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CRUNTIME /MD)
else()
    set(CRUNTIME /MT)
endif()
set(DEBUGMODE no)
set(LIB_DIR ${CURRENT_INSTALLED_DIR}/lib)
set(INCLUDE_DIR ${CURRENT_INSTALLED_DIR}/include)
set(INSTALL_DIR ${CURRENT_PACKAGES_DIR})
file(TO_NATIVE_PATH "${LIB_DIR}" LIB_DIR)
file(TO_NATIVE_PATH "${INCLUDE_DIR}" INCLUDE_DIR)
file(TO_NATIVE_PATH "${INSTALL_DIR}" INSTALL_DIR)
string(CONFIGURE "${CONFIGURE_COMMAND_TEMPLATE}" CONFIGURE_COMMAND)
vcpkg_execute_required_process(
    COMMAND ${CONFIGURE_COMMAND}
    WORKING_DIRECTORY ${SCRIPTS_DIR}
    LOGNAME config-${TARGET_TRIPLET}-rel
)
# Handle build output directory
file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" OUTDIR)
file(MAKE_DIRECTORY "${OUTDIR}")
message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} /f Makefile.msvc rebuild OUTDIR=${OUTDIR}
    WORKING_DIRECTORY ${SCRIPTS_DIR}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")

message(STATUS "Installing ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} /f Makefile.msvc install OUTDIR=${OUTDIR}
    WORKING_DIRECTORY ${SCRIPTS_DIR}
    LOGNAME install-${TARGET_TRIPLET}-rel
)
message(STATUS "Installing ${TARGET_TRIPLET}-rel done")


#
# Debug
#

message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CRUNTIME /MDd)
else()
    set(CRUNTIME /MTd)
endif()
set(DEBUGMODE yes)
set(LIB_DIR ${CURRENT_INSTALLED_DIR}/debug/lib)
set(INSTALL_DIR ${CURRENT_PACKAGES_DIR}/debug)
file(TO_NATIVE_PATH "${LIB_DIR}" LIB_DIR)
file(TO_NATIVE_PATH "${INSTALL_DIR}" INSTALL_DIR)
string(CONFIGURE "${CONFIGURE_COMMAND_TEMPLATE}" CONFIGURE_COMMAND)

vcpkg_execute_required_process(
    COMMAND ${CONFIGURE_COMMAND}
    WORKING_DIRECTORY ${SCRIPTS_DIR}
    LOGNAME config-${TARGET_TRIPLET}-dbg
)
# Handle build output directory
file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" OUTDIR)
file(MAKE_DIRECTORY "${OUTDIR}")
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")

message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} /f Makefile.msvc rebuild OUTDIR=${OUTDIR}
    WORKING_DIRECTORY ${SCRIPTS_DIR}
    LOGNAME build-${TARGET_TRIPLET}-dbg
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} /f Makefile.msvc install OUTDIR=${OUTDIR}
    WORKING_DIRECTORY ${SCRIPTS_DIR}
    LOGNAME install-${TARGET_TRIPLET}-dbg
)
message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")

#
# Cleanup
#

# You have to define LIB(E)XSLT_STATIC or not, depending on how you link
file(READ ${CURRENT_PACKAGES_DIR}/include/libxslt/xsltexports.h XSLTEXPORTS_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(LIBXSLT_STATIC)" "0" XSLTEXPORTS_H "${XSLTEXPORTS_H}")
else()
    string(REPLACE "!defined(LIBXSLT_STATIC)" "1" XSLTEXPORTS_H "${XSLTEXPORTS_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libxslt/xsltexports.h "${XSLTEXPORTS_H}")

file(READ ${CURRENT_PACKAGES_DIR}/include/libexslt/exsltexports.h EXSLTEXPORTS_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(LIBEXSLT_STATIC)" "0" EXSLTEXPORTS_H "${EXSLTEXPORTS_H}")
else()
    string(REPLACE "!defined(LIBEXSLT_STATIC)" "1" EXSLTEXPORTS_H "${EXSLTEXPORTS_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libexslt/exsltexports.h "${EXSLTEXPORTS_H}")

# Remove tools and debug include directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/tools)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# The makefile builds both static and dynamic libraries, so remove the ones we don't want
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libxslt_a.lib ${CURRENT_PACKAGES_DIR}/lib/libexslt_a.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt_a.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libexslt_a.lib)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libxslt.lib ${CURRENT_PACKAGES_DIR}/lib/libexslt.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libexslt.lib)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    # Rename the libs to match the dynamic lib names
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libxslt_a.lib ${CURRENT_PACKAGES_DIR}/lib/libxslt.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libexslt_a.lib ${CURRENT_PACKAGES_DIR}/lib/libexslt.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt_a.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libexslt_a.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libexslt.lib)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxslt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libxslt/COPYING ${CURRENT_PACKAGES_DIR}/share/libxslt/copyright)

vcpkg_copy_pdbs()