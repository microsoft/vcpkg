list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DTOOLCHAIN_ENABLE_Fortran:BOOL=ON")

function(setup_fortran)
  if(EXISTS "${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/intel-msvc-env.cmake")
    message("Loading Intel Fortran environment ....")
    include("${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/intel-msvc-env.cmake")
    setup_intel_msvc_env()
  endif()
endfunction()

function(${PORT}_setup)
  default_setup()
  setup_fortran()
endfunction()
