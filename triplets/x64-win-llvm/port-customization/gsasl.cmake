function(${PORT}_setup)
  default_setup()
  set(ENV{AR} "llvm-ar.exe")
endfunction()

list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_AR=llvm-ar.exe")
