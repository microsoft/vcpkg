# NOTES
# - if you get a codepage/unicode related error (non-critical) during configuration,
#   ignore it or, try switching the console codepage to windows english (`chcp 1252`)
# - the build breaks with "missing pthreads" if --enable-fftw3(f) is added (if fftw3
#   is not added, the embedded ooura fft lib is used)
# - the port uses ffmpeg and libsndfile as dependencies and also depends on possibilty to acquire waf and pkg-config(-lite) in vcpkg.
# - crt-linkage is handled here, not in the generic waf-configure function because it is controlled via a patch to the aubio wscript
#   Waf seems to have no generic way to switch crt-linkage.
# - The static build works, but: vcpkg's static ffmpegs build is fake ;), therefore it is still required to make the ffmpeg dlls 
#   available in order to run exectables with statically linked aubio.

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aubio-3c230fae309e9ea3298783368dd71bae6172359a)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aubio/aubio/archive/3c230fae309e9ea3298783368dd71bae6172359a.zip"
    FILENAME "aubio-0.4.6-3c230f.zip"
    SHA512 081fe59612f0b1860f465208739b1377869c64b91cecf4a6f6fbdea19204b801c650ff956b34be5988ef1905f3546d3c55846037487e0b34b014f1adbb68629c
)
vcpkg_extract_source_archive(${ARCHIVE})

# Pkg-config is equired by aubio to detect ffmpeg and libsndfile
vcpkg_find_acquire_program(PKG-CONFIG)

# Waf depends on python, so this also installs python3
vcpkg_acquire_waf()

# Configure pkg-config dir
get_filename_component(PKG_CONFIG_DIR ${PKG-CONFIG} DIRECTORY)
# Add pkg-config and vcpkg-bin-dir to environment search path
set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/debug/bin;${PKG_CONFIG_DIR};$ENV{PATH}")
# Set pkg-config search-path
set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")

# Add waf executable if missing
if(NOT EXISTS "${SOURCE_PATH}/waf")
  file(COPY "${WAF_DIR}/waf" DESTINATION "${SOURCE_PATH}")
endif()

# Add arguments for crt linkage and library linkage
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/crt_lib_linkage.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/aubio-5.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_waf(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      --library-linkage=${VCPKG_LIBRARY_LINKAGE}
      --crt-linkage=${VCPKG_CRT_LINKAGE}
      --enable-sndfile
      --enable-avcodec
      --disable-docs
      --verbose
    # OPTIONS_DEBUG
    # OPTIONS_RELEASE
    OPTIONS_BUILD
      --library-linkage=${VCPKG_LIBRARY_LINKAGE}
      --verbose
      --notests
    # OPTIONS_BUILD_RELEASE
    # OPTIONS_BUILD_DEBUG
    # TARGETS
)

# Postinstall cleanup debug
message(STATUS "Cleaning up build")
# Remove unused files
# Debug executable and include folder
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(GLOB DEBUG_EXECS ${CURRENT_PACKAGES_DIR}/debug/bin/*)
file(REMOVE ${DEBUG_EXECS})
# In release branch move execs to tools
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/aubio)
file(GLOB RELEASE_EXECS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB RELEASE_EXE_SYMBOLS ${CURRENT_PACKAGES_DIR}/bin/*.pdb)
FILE(COPY ${RELEASE_EXECS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/aubio)
FILE(REMOVE ${RELEASE_EXECS} ${RELEASE_EXE_SYMBOLS})

# Prepare (re-)moving dynamic libs
file(GLOB DEBUG_DLLS ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll ${CURRENT_PACKAGES_DIR}/debug/lib/*.pdb)
file(GLOB RELEASE_DLLS ${CURRENT_PACKAGES_DIR}/lib/*.dll ${CURRENT_PACKAGES_DIR}/lib/*.pdb)

if(${VCPKG_LIBRARY_LINKAGE} MATCHES "dynamic")
  # Move dlls
  file(COPY ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
  file(COPY ${RELEASE_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE ${DEBUG_DLLS} ${RELEASE_DLLS})
elseif(${VCPKG_LIBRARY_LINKAGE} MATCHES "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright and credentials
file(COPY 
    ${SOURCE_PATH}/COPYING 
    ${SOURCE_PATH}/AUTHORS 
    ${SOURCE_PATH}/ChangeLog 
    ${SOURCE_PATH}/README.md 
  DESTINATION 
    ${CURRENT_PACKAGES_DIR}/share/aubio)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/aubio/COPYING ${CURRENT_PACKAGES_DIR}/share/aubio/copyright)

# TODO
# Add python script for dynamic symbols export in dynamic linking
