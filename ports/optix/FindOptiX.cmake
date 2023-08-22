# This is the hardest-trying FindOptiX.cmake in existence for OptiX > 7.0.0.
#
# Defines:
# - OptiX_FOUND
# - OptiX_INCLUDE_DIR
# - OptiX_ROOT_DIR
# - OptiX_VERSION

list(APPEND OptiX_POTENTIAL_DIRS
  "${OptiX_DIR}"
  "${OptiX_INSTALL_DIR}"       # https://github.com/owl-project/owl uses this style.
  "${OptiX_PATH}"
  "${OptiX_ROOT}"
  "${OptiX_ROOT_DIR}"          # https://github.com/nvidia/visrtx uses this style.
  "${OptiX_ROOT_PATH}"

  "${OPTIX_DIR}"
  "${OPTIX_INSTALL_DIR}"
  "${OPTIX_PATH}"
  "${OPTIX_ROOT}"
  "${OPTIX_ROOT_DIR}"
  "${OPTIX_ROOT_PATH}"

  "$ENV{OptiX_DIR}"
  "$ENV{OptiX_INSTALL_DIR}"
  "$ENV{OptiX_PATH}"
  "$ENV{OptiX_ROOT}"
  "$ENV{OptiX_ROOT_DIR}"
  "$ENV{OptiX_ROOT_PATH}"

  "$ENV{OPTIX_DIR}"
  "$ENV{OPTIX_INSTALL_DIR}"
  "$ENV{OPTIX_PATH}"
  "$ENV{OPTIX_ROOT}"
  "$ENV{OPTIX_ROOT_DIR}"
  "$ENV{OPTIX_ROOT_PATH}"

  "$ENV{PATH}"                 # Explicitly included as a package manager (e.g. vcpkg) may remove system paths.
)
list(APPEND OptiX_POTENTIAL_SUFFIXES
  "/OptiX"
)

if(WIN32)
  list(APPEND OptiX_POTENTIAL_DIRS
    "$ENV{PROGRAMDATA}"
    "$ENV{PROGRAMFILES}"
    "$ENV{PROGRAMFILES\(X86\)}"

    "$ENV{PROGRAMDATA}/NVIDIA"
    "$ENV{PROGRAMFILES}/NVIDIA"
    "$ENV{PROGRAMFILES\(X86\)}/NVIDIA"

    "$ENV{PROGRAMDATA}/NVIDIA Corporation"
    "$ENV{PROGRAMFILES}/NVIDIA Corporation"
    "$ENV{PROGRAMFILES\(X86\)}/NVIDIA Corporation"
  )
elseif(LINUX)
  list(APPEND OptiX_POTENTIAL_DIRS
    "/include"
    "/include/nvidia"
    "/lib"
    "/lib/nvidia"
    "/lib64"
    "/lib64/nvidia"
    "/opt"
    "/opt/nvidia"

    "/usr"
    "/usr/include"
    "/usr/include/nvidia"
    "/usr/lib"
    "/usr/lib/nvidia"
    "/usr/lib64"
    "/usr/lib64/nvidia"
    "/usr/opt"
    "/usr/opt/nvidia"

    "/usr/local"
    "/usr/local/include"
    "/usr/local/include/nvidia"
    "/usr/local/lib"
    "/usr/local/lib/nvidia"
    "/usr/local/lib64"
    "/usr/local/lib64/nvidia"
    "/usr/local/opt"
    "/usr/local/opt/nvidia"

    "/var"
    "/var/include"
    "/var/include/nvidia"
    "/var/lib"
    "/var/lib/nvidia"
    "/var/lib64"
    "/var/lib64/nvidia"
    "/var/opt"
    "/var/opt/nvidia"

    "/var/local"
    "/var/local/include"
    "/var/local/include/nvidia"
    "/var/local/lib"
    "/var/local/lib/nvidia"
    "/var/local/lib64"
    "/var/local/lib64/nvidia"
    "/var/local/opt"
    "/var/local/opt/nvidia"

    "$ENV{CPATH}"              # Explicitly included as a package manager (e.g. vcpkg) may remove compiler paths.
    "$ENV{C_INCLUDE_PATH}"     # Explicitly included as a package manager (e.g. vcpkg) may remove compiler paths.
    "$ENV{CPLUS_INCLUDE_PATH}" # Explicitly included as a package manager (e.g. vcpkg) may remove compiler paths.
  )
  list(APPEND OptiX_POTENTIAL_SUFFIXES
    "/optix" # Linux is case sensitive.
    "/OPTIX" # Linux is case sensitive.
  )
endif()

set(OptiX_VALID_POTENTIAL_DIRS)
foreach(OptiX_POTENTIAL_DIR IN LISTS OptiX_POTENTIAL_DIRS)
  if(IS_DIRECTORY "${OptiX_POTENTIAL_DIR}")
    list(APPEND OptiX_VALID_POTENTIAL_DIRS "${OptiX_POTENTIAL_DIR}")
  
    foreach(OptiX_POTENTIAL_SUFFIX IN LISTS OptiX_POTENTIAL_SUFFIXES)
      if(IS_DIRECTORY "${OptiX_POTENTIAL_DIR}${OptiX_POTENTIAL_SUFFIX}")
        list(APPEND OptiX_VALID_POTENTIAL_DIRS "${OptiX_POTENTIAL_DIR}${OptiX_POTENTIAL_SUFFIX}")
      endif()
      
      file(GLOB OptiX_POTENTIAL_VERSIONED_DIRS "${OptiX_POTENTIAL_DIR}${OptiX_POTENTIAL_SUFFIX}*")
      foreach(OptiX_POTENTIAL_VERSIONED_DIR IN LISTS OptiX_POTENTIAL_VERSIONED_DIRS)
        string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" OptiX_POTENTIAL_VERSION "${OptiX_POTENTIAL_VERSIONED_DIR}")
        if(NOT OptiX_POTENTIAL_VERSION OR OptiX_POTENTIAL_VERSION VERSION_GREATER_EQUAL "7.0.0")
          list(PREPEND OptiX_VALID_POTENTIAL_DIRS "${OptiX_POTENTIAL_VERSIONED_DIR}") # Prepended to ensure the latest version is found first.
        endif()
      endforeach()
    endforeach()
  endif()
endforeach()

message(DEBUG " OptiX_VALID_POTENTIAL_DIRS: ")
foreach(OptiX_VALID_POTENTIAL_DIR IN LISTS OptiX_VALID_POTENTIAL_DIRS)
  message(DEBUG " ${OptiX_VALID_POTENTIAL_DIR} ")
endforeach()

find_path(
  OptiX_ROOT_DIR
  NAMES
    "include/optix.h"
  PATHS
    ${OptiX_VALID_POTENTIAL_DIRS}
)

if (OptiX_ROOT_DIR)
  set(OptiX_INCLUDE_DIR "${OptiX_ROOT_DIR}/include")

  file(READ "${OptiX_INCLUDE_DIR}/optix.h" OptiX_HEADER_FILE)
  string(REGEX MATCH "#define OPTIX_VERSION ([0-9]*)" _ "${OptiX_HEADER_FILE}")
  set(OptiX_VERSION_CODE "${CMAKE_MATCH_1}")
  math(EXPR OptiX_MAJOR_VERSION "${OptiX_VERSION_CODE} / 10000")
  math(EXPR OptiX_MINOR_VERSION "(${OptiX_VERSION_CODE} % 10000) / 100")
  math(EXPR OptiX_MICRO_VERSION "${OptiX_VERSION_CODE} % 100")
  set(OptiX_VERSION "${OptiX_MAJOR_VERSION}.${OptiX_MINOR_VERSION}.${OptiX_MICRO_VERSION}")
  
  # Not allowed in scripting mode.
  # add_library(OptiX::OptiX INTERFACE IMPORTED)
  # target_include_directories(OptiX::OptiX INTERFACE "${OptiX_INCLUDE_DIR}")
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
