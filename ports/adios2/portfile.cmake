vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ornladios/ADIOS2
    REF "v${VERSION}"
    SHA512 15062ef10a70a8d0ee0b296302b0052c8150c9d315ac4b4f093728c36484e881d677ba8687d316090251d5939fcf00cef55fef43fc6f6fe04881b2a93234b5ec
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
list(APPEND disabled_options SZ LIBPRESSIO MGARD DAOS DataMan DataSpaces MHS SST BP5 IME Fortran SysVShMem Profiling)
list(TRANSFORM disabled_options PREPEND "-DADIOS2_USE_")
list(TRANSFORM disabled_options APPEND  ":BOOL=OFF")
set(enabled_options "")
list(APPEND enabled_options BZip2 Blosc2 PNG ZeroMQ HDF5 Endian_Reverse Sodium)
list(TRANSFORM enabled_options PREPEND "-DADIOS2_USE_")
list(TRANSFORM enabled_options APPEND  ":BOOL=OFF")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      ${disabled_options}
      ${enabled_options}
      -DBUILD_TESTING=OFF
      -DADIOS2_BUILD_EXAMPLES=OFF
      -DADIOS2_INSTALL_GENERATE_CONFIG=OFF
    MAYBE_UNUSED_VARIABLES
      ADIOS2_USE_DAOS
      ADIOS2_USE_DataMan
      ADIOS2_USE_DataSpaces
      ADIOS2_USE_SysVShMem
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

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
