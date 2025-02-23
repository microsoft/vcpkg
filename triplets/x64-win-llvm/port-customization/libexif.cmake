list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_AR=llvm-ar.exe")
set(ENV{AR} "llvm-ar.exe")