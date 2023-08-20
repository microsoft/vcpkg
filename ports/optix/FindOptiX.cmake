# Defines:
# - OptiX_FOUND
# - OptiX_INCLUDE_DIR
# - OptiX_ROOT_DIR
# - OptiX_VERSION
# - Interface library target OptiX::OptiX.

### TODO: Find OptiX_ROOT_DIR.

if (OptiX_ROOT_DIR)
  set(OptiX_INCLUDE_DIR "${OptiX_ROOT_DIR}/include")

  ### TODO: Extract OptiX_VERSION from ${OptiX_INCLUDE_DIR}/optix.h.
  
  add_library(OptiX::OptiX INTERFACE IMPORTED)
  target_include_directories(OptiX::OptiX INTERFACE ${OptiX_INCLUDE_DIR})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  OptiX
  FOUND_VAR
    OptiX_FOUND
  REQUIRED_VARS
    OptiX_INCLUDE_DIR
    OptiX_ROOT_DIR
    OptiX_VERSION
)