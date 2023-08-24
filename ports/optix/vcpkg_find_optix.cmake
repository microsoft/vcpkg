function(vcpkg_find_optix)
  cmake_parse_arguments(PARSE_ARGV 0 arg "" "OUT_OPTIX_ROOT;OUT_OPTIX_VERSION" "")

  if(NOT DEFINED arg_OUT_OPTIX_ROOT)
    message(FATAL_ERROR "vcpkg_find_optix() requires an OUT_OPTIX_ROOT argument.")
  endif()

  list(APPEND OPTIX_POTENTIAL_DIRS
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
  list(APPEND OPTIX_POTENTIAL_SUFFIXES
    "/OptiX"
  )
  
  if(WIN32)
    list(APPEND OPTIX_POTENTIAL_DIRS
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
    list(APPEND OPTIX_POTENTIAL_DIRS
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
    list(APPEND OPTIX_POTENTIAL_SUFFIXES
      "/optix" # Linux is case sensitive.
      "/OPTIX" # Linux is case sensitive.
    )
  endif()
  
  set(OPTIX_VALID_POTENTIAL_DIRS)
  foreach(OPTIX_POTENTIAL_DIR IN LISTS OPTIX_POTENTIAL_DIRS)
    if(IS_DIRECTORY "${OPTIX_POTENTIAL_DIR}")
      list(APPEND OPTIX_VALID_POTENTIAL_DIRS "${OPTIX_POTENTIAL_DIR}")
    
      foreach(OPTIX_POTENTIAL_SUFFIX IN LISTS OPTIX_POTENTIAL_SUFFIXES)
        if(IS_DIRECTORY "${OPTIX_POTENTIAL_DIR}${OPTIX_POTENTIAL_SUFFIX}")
          list(APPEND OPTIX_VALID_POTENTIAL_DIRS "${OPTIX_POTENTIAL_DIR}${OPTIX_POTENTIAL_SUFFIX}")
        endif()
        
        file(GLOB OPTIX_POTENTIAL_VERSIONED_DIRS "${OPTIX_POTENTIAL_DIR}${OPTIX_POTENTIAL_SUFFIX}*")
        foreach(OPTIX_POTENTIAL_VERSIONED_DIR IN LISTS OPTIX_POTENTIAL_VERSIONED_DIRS)
          string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" OPTIX_POTENTIAL_VERSION "${OPTIX_POTENTIAL_VERSIONED_DIR}")
          if(NOT OPTIX_POTENTIAL_VERSION OR OPTIX_POTENTIAL_VERSION VERSION_GREATER_EQUAL "${VERSION}")
            list(PREPEND OPTIX_VALID_POTENTIAL_DIRS "${OPTIX_POTENTIAL_VERSIONED_DIR}") # Prepended to ensure the latest version is found first.
          endif()
        endforeach()
      endforeach()
    endif()
  endforeach()
  
  find_path(OPTIX_ROOT NAMES "include/optix.h" PATHS ${OPTIX_VALID_POTENTIAL_DIRS})
  
  if (OPTIX_ROOT)
    file(READ "${OPTIX_ROOT}/include/optix.h" OPTIX_HEADER_FILE)
    string(REGEX MATCH "#define OPTIX_VERSION ([0-9]*)" _ "${OPTIX_HEADER_FILE}")
    set(OPTIX_VERSION_CODE "${CMAKE_MATCH_1}")
    math(EXPR OPTIX_MAJOR_VERSION "${OPTIX_VERSION_CODE} / 10000")
    math(EXPR OPTIX_MINOR_VERSION "(${OPTIX_VERSION_CODE} % 10000) / 100")
    math(EXPR OPTIX_MICRO_VERSION "${OPTIX_VERSION_CODE} % 100")
    set(OPTIX_VERSION "${OPTIX_MAJOR_VERSION}.${OPTIX_MINOR_VERSION}.${OPTIX_MICRO_VERSION}")
  endif()
  
  if(NOT OPTIX_ROOT)
    message(FATAL_ERROR 
      "Unable to locate OptiX on system. Please download and install OptiX ${VERSION} or higher from:"
      "\n    https://developer.nvidia.com/designworks/optix/download\n"
      "If you are certain that OptiX is already installed, please set the OptiX_INSTALL_DIR environment variable to its location.\n")
  elseif(OPTIX_VERSION VERSION_LESS VERSION)
    message(FATAL_ERROR 
      "Located OptiX ${OPTIX_VERSION} on system, but ${VERSION} or higher is required. Please download and install OptiX ${VERSION} or higher from:"
      "\n    https://developer.nvidia.com/designworks/optix/download\n"
      "If you are certain that OptiX ${VERSION} or higher is already installed, please set the OptiX_INSTALL_DIR environment variable to its location.\n")
  endif()

  set("${arg_OUT_OPTIX_ROOT}" "${OPTIX_ROOT}" PARENT_SCOPE)
  if(DEFINED arg_OUT_OPTIX_VERSION)
    set("${arg_OUT_OPTIX_VERSION}" "${OPTIX_VERSION}" PARENT_SCOPE)
  endif()
endfunction()
