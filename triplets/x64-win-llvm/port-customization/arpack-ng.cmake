list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DTOOLCHAIN_ENABLE_Fortran:BOOL=ON")

if(NOT DEP_INFO_RUN)
  message("Loading Intel environment ....")
  include("${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/intel-msvc-env.cmake")
  setup_intel_msvc_env()
endif()