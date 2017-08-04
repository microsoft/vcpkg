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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message("openblas currenly only supports dynamic library linkage")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openblas-0.2.19)
vcpkg_download_distfile(ARCHIVE
    URLS "https://codeload.github.com/xianyi/OpenBLAS/zip/v0.2.19"
    FILENAME "openblas-v0.2.19.zip"
    SHA512 d95dcd1ca5b3bdc5355969d10c22486f7e32f7dfc3a418b5d0a979d030e9f2ed242d2d78267a5896aa83d27b6041e13ee4c6694f9a589765535011eb22dad9e2
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/install-openblas.patch"
)

# openblas require perl to generate .def for exports
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DTARGET=NEHALEM -DBUILD_WITHOUT_LAPACK=ON
    # PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)


vcpkg_install_cmake()

# openblas do not make the config file , so I manually made this
# but I think in most case, libraries will not include these files, they define their own used function prototypes
# this is only to quite vcpkg
file(COPY ${CMAKE_CURRENT_LIST_DIR}/openblas_common.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(COPY ${SOURCE_PATH}/config.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/config.h ${CURRENT_PACKAGES_DIR}/include/openblas_config.h)

file(READ ${SOURCE_PATH}/cblas.h CBLAS_H)
string(REPLACE "#include \"common.h\"" "#include \"openblas_common.h\"" CBLAS_H "${CBLAS_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/cblas.h "${CBLAS_H}")

# openblas is BSD
file(COPY ${CURRENT_BUILDTREES_DIR}/src/OpenBLAS-0.2.19/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openblas)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openblas/LICENSE ${CURRENT_PACKAGES_DIR}/share/openblas/copyright)

vcpkg_copy_pdbs()
