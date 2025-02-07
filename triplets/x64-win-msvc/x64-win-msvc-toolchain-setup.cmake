include_guard(GLOBAL)

function(clean_env)
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../common/env-whitelist.cmake")

  set(systemroot "$ENV{SystemRoot}")
  string(REPLACE "\\" "/" systemroot "${systemroot}")

  set(PATH_VAR 
      ${pwsh_path}
      "${systemroot}/Microsoft.NET/Framework64/v4.0.30319"
      "${systemroot}/system32"
      "${systemroot}"
      "${systemroot}/System32/Wbem"
      "${systemroot}/System32/WindowsPowerShell/v1.0/"
  )

  cmake_path(CONVERT "${PATH_VAR}" TO_NATIVE_PATH_LIST ENV{PATH} NORMALIZE)
endfunction()

function(setup_msvc)
  if(EXISTS "${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/msvc-env.cmake")
      message("Loading MSVC environment ....")
      include("${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/msvc-env.cmake")
      setup_msvc_env()
  endif()
endfunction()

function(setup_cuda)
  if(EXISTS "${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/cuda-env.cmake")
    include("${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/cuda-env.cmake")
    setup_cuda_env()
  endif()
endfunction()

function(default_setup)
  setup_msvc()
  setup_cuda()
endfunction()