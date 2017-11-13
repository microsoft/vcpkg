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

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "openblas can only be built for x64 currently")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/clapack-3.2.1-CMAKE)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz"
    FILENAME "clapack-3.2.1.tgz"
    SHA512 cf19c710291ddff3f6ead7d86bdfdeaebca21291d9df094bf0a8ef599546b007757fb2dbb19b56511bb53ef7456eac0c73973b9627bf4d02982c856124428b49
)
vcpkg_extract_source_archive(${ARCHIVE})

# apply patch can not add file
file(COPY ${CMAKE_CURRENT_LIST_DIR}/lapack.def DESTINATION ${SOURCE_PATH}/SRC)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/use-other-blas-and-install-include.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}

    # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/clapack)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/clapack/COPYING ${CURRENT_PACKAGES_DIR}/share/clapack/copyright)

vcpkg_copy_pdbs()
