
#if(NOT PORT MATCHES "(icu)" )
  # Something seems to interfer with PATH in ICU builds
  list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS 
                      "-DVCPKG_USE_SANITIZERS:BOOL=TRUE"
              )
  if(PORT MATCHES "(openssl|boost|libpq|icu)" OR port_contents MATCHES "(vcpkg_configure_meson|_msbuild|_nmake)")
      list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS 
                  "-DVCPKG_USE_COMPILER_FOR_LINKAGE:BOOL=FALSE"
          )
  else()
      message(STATUS "Found unsupported portfile. Deactivating linkage via compiler")
  endif()

#endif()

if(PORT MATCHES "(icu)" AND 1 )
  # https://developercommunity.visualstudio.com/t/asan-missing-symbols-when-linking-with-nodefaultli/1300874
  function(vcpkg_user_setup_env_release)
    set(ENV{_LINK_} "-wholearchive:clang_rt.asan_dynamic-x86_64.lib -wholearchive:clang_rt.asan_dynamic_runtime_thunk-x86_64.lib")
# vcruntime.lib msvcprt.lib ucrt.lib kernel32.lib vcasan.lib legacy_stdio_wide_specifiers.lib
  endfunction()
  function(vcpkg_user_setup_env_debug)
    set(ENV{_LINK_} "-wholearchive:clang_rt.asan_dbg_dynamic-x86_64.lib -wholearchive:clang_rt.asan_dbg_dynamic_runtime_thunk-x86_64.lib")
# vcruntimed.lib msvcprtd.lib ucrtd.lib kernel32.lib vcasand.lib legacy_stdio_wide_specifiers.lib
  endfunction()
  function(vcpkg_user_setup_env_release_restore)
    unset(ENV{_LINK_})
  endfunction()
  function(vcpkg_user_setup_env_debug_restore)
    unset(ENV{_LINK_})
  endfunction()
endif()