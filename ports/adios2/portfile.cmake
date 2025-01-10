vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ornladios/ADIOS2
    REF "v${VERSION}"
    SHA512 1a81ddb4d862b27a0ae9e17eaee7a16e6456f87a1740a857907b5766016bfcbf2abe4a599024d794d3f0637196c280641fe73e0d0de525b27510364dd9cffd20
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mpi     ADIOS2_USE_MPI
        cuda    ADIOS2_USE_CUDA
        python  ADIOS2_USE_Python # requires numpy / mpi4py; so not exposed in the manifest yet
        zfp     ADIOS2_USE_ZFP
)

set(disabled_options "")
list(APPEND disabled_options SZ LIBPRESSIO MGARD DAOS DataMan DataSpaces MHS SST IME Fortran SysVShMem Profiling)
list(TRANSFORM disabled_options PREPEND "-DADIOS2_USE_")
list(TRANSFORM disabled_options APPEND  ":BOOL=OFF")
set(enabled_options "")
list(APPEND enabled_options BZip2 Blosc2 PNG ZeroMQ HDF5 Endian_Reverse Sodium)
list(TRANSFORM enabled_options PREPEND "-DADIOS2_USE_")
list(TRANSFORM enabled_options APPEND  ":BOOL=OFF")

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
set(PATH_BACKUP "$ENV{PATH}")
vcpkg_add_to_path("${PERL_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DCMAKE_CXX_STANDARD=11
      ${FEATURE_OPTIONS}
      ${disabled_options}
      ${enabled_options}
      -DBUILD_TESTING=OFF
      -DADIOS2_BUILD_EXAMPLES=OFF
      -DADIOS2_INSTALL_GENERATE_CONFIG=OFF
      -DEVPATH_USE_ENET=OFF
      -DEVPATH_TRANSPORT_MODULES=OFF
      "-DPERL_EXECUTABLE=${PERL}"
    MAYBE_UNUSED_VARIABLES
      ADIOS2_USE_DAOS
      ADIOS2_USE_DataMan
      ADIOS2_USE_DataSpaces
      ADIOS2_USE_SysVShMem
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

set(ENV{PATH} "${PATH_BACKUP}")

set(tools "adios2_reorganize" "bpls")
if(ADIOS2_USE_MPI)
  list(APPEND tools "adios2_reorganize_mpi" "adios2_iotest")
endif()

vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/adios2_deactivate_bp" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/adios2_deactivate_bp")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/adios2/toolkit/sst/dp" "${CURRENT_PACKAGES_DIR}/include/adios2/toolkit/sst/util")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
