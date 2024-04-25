set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_BUILD_TYPE release)

set(VCPKG_MAKE_CONFIGURE_CACHE "${CMAKE_CURRENT_LIST_DIR}/../../scripts/toolchains/windows.configure.txt") # ${SCRIPTS} could be used here but the compiler detection does not know about that.
set(VCPKG_HASH_ADDITIONAL_FILES "${VCPKG_MAKE_CONFIGURE_CACHE}")
