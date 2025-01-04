list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DTOOLCHAIN_ENABLE_Fortran:BOOL=ON")

if(NOT DEP_INFO_RUN)
  message("Loading Intel environment ....")
  include("${_VCPKG_INSTALLED_DIR}/${TARGET_TRIPLET}/share/intel-hpc/intel-msvc-env.cmake")
endif()