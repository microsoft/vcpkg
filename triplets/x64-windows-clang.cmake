set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_PLATFORM_TOOLSET v142) 
set(VCPKG_SKIP_POST_BUILD_LIB_ARCH_CHECK "ON") # Skips post build architecture checks of libs and dlls. Only works with VS link.exe
set(LLVM_BINDIR "C:\\Program Files\\LLVM\\bin")
set(ENV{Path} "${LLVM_BINDIR};$ENV{Path}")
set(VCPKG_C_COMPILER "clang")
set(VCPKG_CXX_COMPILER "clang++")
set(VCPKG_LINKER "lld-link")
set(VCPKG_AR "llvm-ar.exe")
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchain/win-clang-toolchain.cmake")
set(VCPKG_DEFAULT_CMAKE_GENERATOR Ninja)
#set(VCPKG_LOAD_ENVIROMNENT_BATCH "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Auxiliary\\Build\\vcvars64.bat")
set(VCPKG_FORCE_LOAD_VCVARS_ENV "true")
#set(ENV{VCPKG_KEEP_ENV_VARS} "Path;INCLUDE;LIB") # start building this triplet from a dev cmd with vcvars loaded. Needs to be set manually for some reason 
#set(VCPKG_C_FLAGS) # Injects additional C build flags
#set(VCPKG_CXX_FLAGS) # Injects additional C++ build flags
#set(VCPKG_C_FLAGS_DEBUG) # Injects additional C build flags in debug mode
#set(VCPKG_CXX_FLAGS_DEBUG) # Injects additional C++ build flags in debug mode
#set(VCPKG_C_FLAGS_RELEASE) # Injects additional C build flags in release mode
#set(VCPKG_CXX_FLAGS_RELEASE) # Injects additional C++ build flags in release mode
#set(VCPKG_LINKER_FLAGS) # Injects additional Linker Flags 