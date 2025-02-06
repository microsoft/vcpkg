include_guard(GLOBAL)

function(clean_env)
  find_program(pwsh_exe NAMES pwsh powershell)
  execute_process(
      COMMAND "${pwsh_exe}" -ExecutionPolicy Bypass -Command "[System.Environment]::GetEnvironmentVariables().Keys | ForEach-Object { \"$_\" }"
      OUTPUT_VARIABLE env_vars
  )
  string(REPLACE "\n" ";" env_vars "${env_vars}")
  string(REGEX REPLACE ";$" "" env_vars "${env_vars}")

  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/env-whitelist.cmake")
  foreach(env_var IN LISTS env_vars)
    message(STATUS "ENV{${env_var}}:$ENV{${env_var}}")
    if(NOT "${env_var}" IN_LIST ENV_WHITELIST)
      message(STATUS "Unsetting ${env_var}")
      #unset(ENV{${env_var}})
    endif()
  endforeach()

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

function(setup_llvm)
  if(EXISTS "${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/llvm-env.cmake")
      message("Loading LLVM environment ....")
      include("${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/env-setup/llvm-env.cmake")
      setup_llvm_env()
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
  setup_llvm()
  setup_cuda()
endfunction()