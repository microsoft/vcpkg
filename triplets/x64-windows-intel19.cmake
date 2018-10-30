set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_PLATFORM_TOOLSET "Intel C++ Compiler 19.0") 
set(VCPKG_SKIP_POST_BUILD_LIB_ARCH_CHECK "ON") # Skips post build architecture checks of libs and dlls. Only works with VS link.exe
#set(VCPKG_C_FLAGS) # Injects additional C build flags
#set(VCPKG_CXX_FLAGS) # Injects additional C++ build flags
#set(VCPKG_C_FLAGS_DEBUG) # Injects additional C build flags in debug mode
#set(VCPKG_CXX_FLAGS_DEBUG) # Injects additional C++ build flags in debug mode
#set(VCPKG_C_FLAGS_RELEASE) # Injects additional C build flags in release mode
#set(VCPKG_CXX_FLAGS_RELEASE) # Injects additional C++ build flags in release mode
#set(VCPKG_LINKER_FLAGS) # Injects additional Linker Flags 