if(PORT STREQUAL "tbb")
    set(VCPKG_C_FLAGS "-mrtm")
    set(VCPKG_CXX_FLAGS "-mrtm")
endif()
if(PORT MATCHES "^(re2)$")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
if(PORT MATCHES "^(arrow|flint|folly|glog|zydis|libirecovery|graphicsmagick)$")
    # arrow implicit deleted default constructor
    # libirecovery missing getopt linkage
    # graphicsmagick -> requires wrapping the allocators in namespace std
    # glog hardcodes builtin expected if build with clang-cl (#if 1 otehrwise #if 0) -> folly sees that. 
    # zydis UTF-16 encoding 
    # TODO: Recheck flint
    message(STATUS "Falling back to cl!")
    unset(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    unset(VCPKG_PLATFORM_TOOLSET)
    set(ENV{PATH} "${PATH_BACKUP}")
endif()