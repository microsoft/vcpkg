set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

## Toolchain setup
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/windows.asan.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON) # Setting VCPKG_CHAINLOAD_TOOLCHAIN_FILE deactivates automatic vcvars setup so reenable it!

set(VCPKG_CMAKE_CONFIGURE_OPTIONS 
      "-DCMAKE_TRY_COMPILE_CONFIGURATION=Release"
    )

include("${CMAKE_CURRENT_LIST_DIR}/asan.port.settings.cmake")