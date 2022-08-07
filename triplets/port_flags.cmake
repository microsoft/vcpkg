if(PORT STREQUAL "tbb")
    set(VCPKG_C_FLAGS "-mrtm")
    set(VCPKG_CXX_FLAGS "-mrtm")
endif()
if(PORT MATCHES "^(re2)$")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
# Note: All gn ports still use cl unless we figure out to pass it a toolchain somehow. 
if(PORT MATCHES "^(arrow|alkali|flint|folly|glog|zydis|graphicsmagick|freerdp|gtk|irrlicht|libde265|llfio|mongo-c-driver|tcl|nvtt)$")
    # alkali -> typedef private void (T::*POnTimer)(void); -> error
    # mongo-c-driver -> strange redefinition error. Couldn't find why it claims that the defs are different. 
    # llfio -> code has correctness issues which cl accepts. (wrong thread_local and friend declaration)
    # gtk -> .res files in archives via /WHOLEARCHIVE not correctly handled by lld-link
    # libde265 -> probably some macro collision
    # arrow implicit deleted default constructor
    # libirecovery missing getopt linkage -> linkage general problem in msbuild ports since autolinkage is deactivated`?
    # graphicsmagick -> requires wrapping the allocators in namespace std
    # glog hardcodes builtin expected if build with clang-cl (#if 1 otehrwise #if 0) -> folly sees that. 
    # zydis,freerdp,irrlicht UTF-16 encoding in rc file
    # tcl -> requires nmake compiler setup
    # nvtt: too complicated compiler dependent behavior to fix quickly. 
    # TODO: Recheck flint
    message(STATUS "Falling back to cl!")
    unset(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    unset(VCPKG_PLATFORM_TOOLSET)
    set(ENV{PATH} "${PATH_BACKUP}")
endif()
if(PORT MATCHES "^itk$" AND "rtk" IN_LIST FEATURES)
    # itk/rtk needs an update to correctly support cuda with clang-cl
    message(STATUS "Falling back to cl!")
    unset(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    unset(VCPKG_PLATFORM_TOOLSET)
    set(ENV{PATH} "${PATH_BACKUP}")
endif()