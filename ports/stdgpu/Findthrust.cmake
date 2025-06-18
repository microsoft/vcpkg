find_path(THRUST_INCLUDE_DIR
          HINTS
          "/usr/include"
          "/usr/local/include"
          "/usr/local/cuda/include"
          NAMES
          "thrust/version.h")

if(THRUST_INCLUDE_DIR)
    file(STRINGS "${THRUST_INCLUDE_DIR}/thrust/version.h"
         THRUST_VERSION_STRING
         REGEX "#define THRUST_VERSION[ \t]+[0-9]+")

    if(THRUST_VERSION_STRING)
        # Extract just the numeric version
        string(REGEX MATCH "[0-9]+" THRUST_VERSION_NUM "${THRUST_VERSION_STRING}")
        
        if(THRUST_VERSION_NUM)
            math(EXPR THRUST_VERSION_MAJOR "${THRUST_VERSION_NUM} / 100000")
            math(EXPR THRUST_VERSION_MINOR "(${THRUST_VERSION_NUM} / 100) % 1000")
            math(EXPR THRUST_VERSION_PATCH "${THRUST_VERSION_NUM} % 100")
            set(THRUST_VERSION "${THRUST_VERSION_MAJOR}.${THRUST_VERSION_MINOR}.${THRUST_VERSION_PATCH}")
        else()
            set(THRUST_VERSION "2.0.0") # Fallback version
        endif()
    else()
        set(THRUST_VERSION "2.0.0") # Fallback version
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(thrust
                                  REQUIRED_VARS THRUST_INCLUDE_DIR
                                  VERSION_VAR THRUST_VERSION)


if(thrust_FOUND)
    add_library(thrust::thrust INTERFACE IMPORTED)
    set_target_properties(thrust::thrust PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${THRUST_INCLUDE_DIR}")

    mark_as_advanced(THRUST_INCLUDE_DIR
                     THRUST_VERSION
                     THRUST_VERSION_MAJOR
                     THRUST_VERSION_MINOR
                     THRUST_VERSION_PATCH)
endif()