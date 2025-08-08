#ifndef Z_VCPKG_FOONATHAN_MEMORY_DEBUG
# if defined(NDEBUG) && !defined(_DEBUG)
#  define Z_VCPKG_FOONATHAN_MEMORY_DEBUG 0
# else
#  define Z_VCPKG_FOONATHAN_MEMORY_DEBUG 1
# endif
#endif

#if Z_VCPKG_FOONATHAN_MEMORY_DEBUG
#  include "config_impl-debug.hpp"
#else
#  include "config_impl-release.hpp"
#endif
