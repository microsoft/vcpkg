# Try to find the Gloo library and headers.
#
#  Gloo_FOUND
#  Gloo_INCLUDE_DIRS
#  Gloo_LIBRARIES

find_path(Gloo_INCLUDE_DIR
  NAMES gloo/common/common.h
  PATHS GLOO_ROOT ENV{GLOO_ROOT}
  PATH_SUFFIXES include
  )

find_library(Gloo_NATIVE_LIBRARY
  NAMES gloo   
  PATHS GLOO_ROOT ENV{GLOO_ROOT}
  PATH_SUFFIXES lib
  )

find_library(Gloo_CUDA_LIBRARY
  NAMES gloo_cuda
  DOC "The Gloo library (with CUDA)"
  PATHS GLOO_ROOT ENV{GLOO_ROOT}
  PATH_SUFFIXES lib
  )

set(Gloo_INCLUDE_DIRS ${Gloo_INCLUDE_DIR})
set(Gloo_LIBRARIES ${Gloo_NATIVE_LIBRARY} ${Gloo_CUDA_LIBRARY})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  Gloo
  FOUND_VAR Gloo_FOUND
  REQUIRED_VARS Gloo_INCLUDE_DIR Gloo_LIBRARIES
  )

mark_as_advanced(Gloo_FOUND)
