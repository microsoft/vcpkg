if(PORT STREQUAL "tbb")
    set(VCPKG_C_FLAGS "-mrtm")
    set(VCPKG_CXX_FLAGS "-mrtm")
endif()
if(PORT MATCHES "^(re2)$")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
if(PORT MATCHES "^(arrow|flint|folly|glog|zydis|libirecovery|graphicsmagick|freerdp|gtk|irrlicht|libde265|cryptopp|llfio)$")
    # llfio -> code has correctness issues which cl accepts. (wrong thread_local and fried declaration)
    # cryptopp misses to pass -m<arch> flags for the clang-cl build
    # gtk -> .res files in archives via /WHOLEARCHIVE not correctly handled by lld-link
    # libde265 -> probably some macro collision
    # arrow implicit deleted default constructor
    # libirecovery missing getopt linkage -> linkage general problem in msbuild ports since autolinkage is deactivated`?
    # graphicsmagick -> requires wrapping the allocators in namespace std
    # glog hardcodes builtin expected if build with clang-cl (#if 1 otehrwise #if 0) -> folly sees that. 
    # zydis,freerdp,irrlicht UTF-16 encoding in rc file
    # TODO: Recheck flint
    message(STATUS "Falling back to cl!")
    unset(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    unset(VCPKG_PLATFORM_TOOLSET)
    set(ENV{PATH} "${PATH_BACKUP}")
endif()