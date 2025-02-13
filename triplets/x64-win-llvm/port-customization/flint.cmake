unset(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
unset(VCPKG_PLATFORM_TOOLSET)

function(${PORT}_setup)
  setup_msvc()
endfunction()
