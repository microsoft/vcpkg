# Defines:
# - OptiX_FOUND
# - OptiX_INCLUDE_DIR
# - OptiX_ROOT_DIR
# - OptiX_VERSION
# - Interface library target OptiX::OptiX.

list(APPEND OptiX_POTENTIAL_DIRS
  "${OptiX_DIR}"
  "${OptiX_INSTALL_DIR}"    # https://github.com/owl-project/owl uses this style.
  "${OptiX_PATH}"
  "${OptiX_ROOT}"
  "${OptiX_ROOT_DIR}"       # https://github.com/nvidia/visrtx uses this style.
  "${OptiX_ROOT_PATH}"
  "$ENV{OptiX_DIR}"
  "$ENV{OptiX_INSTALL_DIR}" 
  "$ENV{OptiX_PATH}"
  "$ENV{OptiX_ROOT}"
  "$ENV{OptiX_ROOT_DIR}"    
  "$ENV{OptiX_ROOT_PATH}"
)

# TODO START: Populate OptiX_POTENTIAL_DIRS per OS. Omit incompatible versions.
if (WIN32)
  #list(APPEND OptiX_POTENTIAL_DIRS "$ENV{%PROGRAMDATA%}/NVIDIA Corporation/OptiX SDK *")
elseif(LINUX)
  #list(APPEND OptiX_POTENTIAL_DIRS "/usr/local/OptiX-*")
elseif(ANDROID)
  #list(APPEND OptiX_POTENTIAL_DIRS "/Developer/NVIDIA/OptiX-*")
endif()
# TODO END

find_path(OptiX_ROOT_DIR NAMES "include/optix.h" PATHS ${OptiX_POTENTIAL_DIRS})

if (OptiX_ROOT_DIR)
  set(OptiX_INCLUDE_DIR "${OptiX_ROOT_DIR}/include")

  file(READ "${OptiX_INCLUDE_DIR}/optix.h" OptiX_HEADER_FILE)
  string(REGEX MATCH "#define OPTIX_VERSION ([0-9]*)" _ "${OptiX_HEADER_FILE}")
  set(OptiX_VERSION_CODE ${CMAKE_MATCH_1})
  math(EXPR OptiX_MAJOR_VERSION "${OptiX_VERSION_CODE} / 10000")
  math(EXPR OptiX_MINOR_VERSION "(${OptiX_VERSION_CODE} % 10000) / 100")
  math(EXPR OptiX_MICRO_VERSION "${OptiX_VERSION_CODE} % 100")
  set(OptiX_VERSION "${OptiX_MAJOR_VERSION}.${OptiX_MINOR_VERSION}.${OptiX_MICRO_VERSION}")
  
  add_library(OptiX::OptiX INTERFACE IMPORTED)
  target_include_directories(OptiX::OptiX INTERFACE "${OptiX_INCLUDE_DIR}")
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
