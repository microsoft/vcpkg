set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

# Compiler tracking won't have the necessary info to detect the compiler yet, since it is not yet installed
# However, since the compiler is a port the abi hash of it will be included any way without detection.
set(VCPKG_DISABLE_COMPILER_TRACKING ON) 
set(TRIPLET_NAME "x64-win-llvm")
set(VCPKG_PLATFORM_TOOLSET "ClangCL")
set(VCPKG_QT_TARGET_MKSPEC "win32-clang-msvc") # For Qt5/QMake
set(LLVM_TRIPLET_DIR "${CMAKE_CURRENT_LIST_DIR}/${TRIPLET_NAME}")
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${LLVM_TRIPLET_DIR}/${TRIPLET_NAME}-toolchain.cmake")

list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS 
  "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}" 
  "-DCMAKE_POLICY_DEFAULT_CMP0149=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0137=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0128=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0126=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0117=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0092=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0091=OLD"
  "-DCMAKE_POLICY_DEFAULT_CMP0067=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0066=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0056=NEW"
  "-DCMAKE_POLICY_DEFAULT_CMP0012=NEW"
)

set(DEP_INFO_RUN OFF)
if(NOT (DEFINED CURRENT_PORT_DIR AND
   DEFINED CURRENT_PACKAGES_DIR AND
   DEFINED CURRENT_BUILDTREES_DIR AND
   DEFINED TARGET_TRIPLET AND
   DEFINED TARGET_TRIPLET_FILE AND
   DEFINED VCPKG_BASE_VERSION AND
   DEFINED VCPKG_MANIFEST_INSTALL AND
   DEFINED CMD))
  set(DEP_INFO_RUN ON)
endif()

set(port_custom_file "${CMAKE_CURRENT_LIST_DIR}/${TRIPLET_NAME}/port-customization/${PORT}.cmake")
# This ensure that a port customization does not trigger a world rebuild.
if(DEFINED PORT AND EXISTS "${port_custom_file}")
  list(APPEND VCPKG_HASH_ADDITIONAL_FILES "${port_custom_file}")
  include("${port_custom_file}")
endif()

include("${LLVM_TRIPLET_DIR}/${TRIPLET_NAME}-toolchain-setup.cmake")

function(setup)
  clean_env()
  if(COMMAND ${PORT}_setup)
    cmake_language(CALL ${PORT}_setup)
  else()
    default_setup()
  endif()
endfunction()

if(NOT DEP_INFO_RUN)
  setup()
endif()