set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

# Compiler tracking won't have the necessary info to detect the compiler yet, since it is not yet installed
# However, since the compiler is a port the abi hash of it will be included any way without detection.
set(VCPKG_DISABLE_COMPILER_TRACKING ON) 
set(TRIPLET_NAME x64-win-msvc)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/${TRIPLET_NAME}/${TRIPLET_NAME}-toolchain.cmake")

if(DEFINED CURRENT_PORT_DIR AND 
   DEFINED CURRENT_PACKAGES_DIR AND 
   DEFINED CURRENT_BUILDTREES_DIR AND
   DEFINED TARGET_TRIPLET AND
   DEFINED TARGET_TRIPLET_FILE AND
   DEFINED VCPKG_BASE_VERSION AND
   DEFINED VCPKG_MANIFEST_INSTALL AND
   DEFINED CMD)
  # This runs env setup scripts so it can only run if we are in the build context of vcpkg
  set(toolchain_setup "${CMAKE_CURRENT_LIST_DIR}/${TRIPLET_NAME}/${TRIPLET_NAME}-toolchain-setup.cmake")
  include("${toolchain_setup}")
endif()

# This ensure that a port customization does not trigger a world rebuild.
set(port_custom_file "${CMAKE_CURRENT_LIST_DIR}/${TRIPLET_NAME}/port-customization/${PORT}.cmake")
if(DEFINED PORT AND EXISTS "${port_custom_file}")
  list(APPEND VCPKG_HASH_ADDITIONAL_FILES "${port_custom_file}")
  include("${port_custom_file}")
endif()