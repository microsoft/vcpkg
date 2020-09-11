# Distributed under the OSI-approved BSD 3-Clause License.

#.rst:
# FindCUDNN
# --------
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module will set the following variables in your project::
#
#  ``CUDNN_FOUND``
#    True if CUDNN found on the local system
#
#  ``CUDNN_INCLUDE_DIRS``
#    Location of CUDNN header files.
#
#  ``CUDNN_LIBRARIES``
#    The CUDNN libraries.
#
#  ``CuDNN::CuDNN``
#    The CUDNN target
#

include(FindPackageHandleStandardArgs)

if(NOT CUDNN_INCLUDE_DIR)
  find_path(CUDNN_INCLUDE_DIR cudnn.h
    HINTS ${CUDA_HOME} ${CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN}
    PATH_SUFFIXES cuda/include include)
endif()

if(NOT CUDNN_LIBRARY)
  find_library(CUDNN_LIBRARY cudnn
    HINTS ${CUDA_HOME} ${CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN}
    PATH_SUFFIXES lib lib64 cuda/lib cuda/lib64 lib/x64)
endif()

if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn.h")
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn.h CUDNN_HEADER_CONTENTS)
  if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version.h")
    file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version.h" CUDNN_VERSION_H_CONTENTS)
    string(APPEND CUDNN_HEADER_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
    unset(CUDNN_VERSION_H_CONTENTS)
  endif()
    string(REGEX MATCH "define CUDNN_MAJOR * +([0-9]+)"
                 CUDNN_VERSION_MAJOR "${CUDNN_HEADER_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_MAJOR * +([0-9]+)" "\\1"
                 CUDNN_VERSION_MAJOR "${CUDNN_VERSION_MAJOR}")
    string(REGEX MATCH "define CUDNN_MINOR * +([0-9]+)"
                 CUDNN_VERSION_MINOR "${CUDNN_HEADER_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_MINOR * +([0-9]+)" "\\1"
                 CUDNN_VERSION_MINOR "${CUDNN_VERSION_MINOR}")
    string(REGEX MATCH "define CUDNN_PATCHLEVEL * +([0-9]+)"
                 CUDNN_VERSION_PATCH "${CUDNN_HEADER_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_PATCHLEVEL * +([0-9]+)" "\\1"
                 CUDNN_VERSION_PATCH "${CUDNN_VERSION_PATCH}")
  if(NOT CUDNN_VERSION_MAJOR)
    set(CUDNN_VERSION "?")
  else()
    set(CUDNN_VERSION "${CUDNN_VERSION_MAJOR}.${CUDNN_VERSION_MINOR}.${CUDNN_VERSION_PATCH}")
  endif()
endif()

set(CUDNN_INCLUDE_DIRS ${CUDNN_INCLUDE_DIR})
set(CUDNN_LIBRARIES ${CUDNN_LIBRARY})
mark_as_advanced(CUDNN_LIBRARY CUDNN_INCLUDE_DIR)

find_package_handle_standard_args(CUDNN
      REQUIRED_VARS  CUDNN_INCLUDE_DIR CUDNN_LIBRARY
      VERSION_VAR    CUDNN_VERSION
)

if(WIN32)
  set(CUDNN_DLL_DIR ${CUDNN_INCLUDE_DIR})
  list(TRANSFORM CUDNN_DLL_DIR APPEND "/../bin")
  find_file(CUDNN_LIBRARY_DLL NAMES cudnn64_${CUDNN_VERSION_MAJOR}.dll PATHS ${CUDNN_DLL_DIR})
endif()

if( CUDNN_FOUND AND NOT TARGET CuDNN::CuDNN )
  if( EXISTS "${CUDNN_LIBRARY_DLL}" )
    add_library( CuDNN::CuDNN      SHARED IMPORTED )
    set_target_properties( CuDNN::CuDNN PROPERTIES
      IMPORTED_LOCATION                 "${CUDNN_LIBRARY_DLL}"
      IMPORTED_IMPLIB                   "${CUDNN_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  else()
    add_library( CuDNN::CuDNN      UNKNOWN IMPORTED )
    set_target_properties( CuDNN::CuDNN PROPERTIES
      IMPORTED_LOCATION                 "${CUDNN_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  endif()
endif()
