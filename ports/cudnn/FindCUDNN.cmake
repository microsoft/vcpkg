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
#  ``CuDNN::*``
#    The CUDNN targets
#

include(FindPackageHandleStandardArgs)
file(GLOB CUDNN_VERSION_DIRS
  LIST_DIRECTORIES true
  "$ENV{CUDA_PATH}/../../../NVIDIA/CUDNN/v[1-9]*.[1-9]*"
)
find_path(CUDNN_INCLUDE_DIR NAMES cudnn.h cudnn_v8.h cudnn_v7.h
  HINTS ${CUDA_TOOLKIT_ROOT} $ENV{CUDA_PATH} $ENV{CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR} ${CUDNN_VERSION_DIRS} /usr/include /usr/include/x86_64-linux-gnu/ /usr/include/aarch64-linux-gnu/
  PATH_SUFFIXES cuda/include include include/11.8 include/12.0 include/12.1 include/12.2 include/12.3 include/12.4 include/12.5 include/12.6)
find_library(_CUDNN_LIBRARY NAMES cudnn cudnn8 cudnn7
  HINTS ${CUDA_TOOLKIT_ROOT} $ENV{CUDA_PATH} $ENV{CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR} ${CUDNN_VERSION_DIRS} /usr/lib/x86_64-linux-gnu/ /usr/include/aarch64-linux-gnu/ /usr/
  PATH_SUFFIXES lib lib64 cuda/lib cuda/lib64 lib/x64 cuda/lib/x64 lib/11.8/x64 lib/12.0/x64 lib/12.1/x64 lib/12.2/x64 lib/12.3/x64 lib/12.4/x64 lib/12.5/x64 lib/12.6/x64)

if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn.h")
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn.h CUDNN_HEADER_CONTENTS)
elseif(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_v8.h")
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn_v8.h CUDNN_HEADER_CONTENTS)
elseif(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_v7.h")
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn_v7.h CUDNN_HEADER_CONTENTS)
endif()
if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version.h")
  file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version.h" CUDNN_VERSION_H_CONTENTS)
  string(APPEND CUDNN_HEADER_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
  unset(CUDNN_VERSION_H_CONTENTS)
elseif(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version_v8.h")
  file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version_v8.h" CUDNN_VERSION_H_CONTENTS)
  string(APPEND CUDNN_HEADER_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
  unset(CUDNN_VERSION_H_CONTENTS)
elseif(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version_v7.h")
  file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version_v7.h" CUDNN_VERSION_H_CONTENTS)
  string(APPEND CUDNN_HEADER_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
  unset(CUDNN_VERSION_H_CONTENTS)
endif()
if(CUDNN_HEADER_CONTENTS)
  string(REGEX MATCH "define CUDNN_MAJOR * +([0-9]+)"
               _CUDNN_VERSION_MAJOR "${CUDNN_HEADER_CONTENTS}")
  string(REGEX REPLACE "define CUDNN_MAJOR * +([0-9]+)" "\\1"
               _CUDNN_VERSION_MAJOR "${_CUDNN_VERSION_MAJOR}")
  string(REGEX MATCH "define CUDNN_MINOR * +([0-9]+)"
               _CUDNN_VERSION_MINOR "${CUDNN_HEADER_CONTENTS}")
  string(REGEX REPLACE "define CUDNN_MINOR * +([0-9]+)" "\\1"
               _CUDNN_VERSION_MINOR "${_CUDNN_VERSION_MINOR}")
  string(REGEX MATCH "define CUDNN_PATCHLEVEL * +([0-9]+)"
               _CUDNN_VERSION_PATCH "${CUDNN_HEADER_CONTENTS}")
  string(REGEX REPLACE "define CUDNN_PATCHLEVEL * +([0-9]+)" "\\1"
               _CUDNN_VERSION_PATCH "${_CUDNN_VERSION_PATCH}")
  if(NOT _CUDNN_VERSION_MAJOR)
    set(_CUDNN_VERSION "?")
  else()
    set(_CUDNN_VERSION "${_CUDNN_VERSION_MAJOR}.${_CUDNN_VERSION_MINOR}.${_CUDNN_VERSION_PATCH}")
  endif()
endif()

mark_as_advanced(_CUDNN_LIBRARY CUDNN_INCLUDE_DIR)

find_package_handle_standard_args(CUDNN
      REQUIRED_VARS  CUDNN_INCLUDE_DIR _CUDNN_LIBRARY
      VERSION_VAR    _CUDNN_VERSION
)

if(NOT CUDNN_FOUND OR TARGET CuDNN::CuDNN )
  return()
endif()

set(CUDNN_LIBRARIES CuDNN::CuDNN)

set(_POSTFIX "")
set(_PREFIX "")

if (NOT WIN32)
  if (NOT BUILD_SHARED_LIBS)
    set(_POSTFIX _static.a)
  else()
    set(_POSTFIX .so.${_CUDNN_VERSION})
  endif()
  set(_PREFIX lib)
else()
  get_filename_component(_CUDA_VERSION ${CUDNN_INCLUDE_DIR} NAME)
  #only dynamic available
  set(_POSTFIX .lib)
endif()

get_filename_component(CUDNN_LIBRARIES_DIR ${_CUDNN_LIBRARY} DIRECTORY)

if (_CUDNN_VERSION_MAJOR EQUAL 7)

  if (WIN32)
    find_file(_DLL NAME "cudnn64_${_CUDNN_VERSION_MAJOR}.dll"
      HINTS "${CUDNN_INCLUDE_DIR}/../bin" "${CUDNN_INCLUDE_DIR}/../../bin/${_CUDA_VERSION}"
    )

    add_library( CuDNN::CuDNN      SHARED IMPORTED )
    set_target_properties( CuDNN::CuDNN PROPERTIES
      IMPORTED_LOCATION                 "${_DLL}"
      IMPORTED_IMPLIB                   "${_CUDNN_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  elseif (BUILD_SHARED_LIBS)
    add_library( CuDNN::CuDNN      SHARED IMPORTED )
    set_target_properties( CuDNN::CuDNN PROPERTIES
      IMPORTED_LOCATION                 "${CUDNN_LIBRARIES_DIR}/${_PREFIX}cudnn${_POSTFIX}"
      INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  else()
    add_library( CuDNN::CuDNN      STATIC IMPORTED )
    set_target_properties( CuDNN::CuDNN PROPERTIES
      IMPORTED_LOCATION                 "${CUDNN_LIBRARIES_DIR}/${_PREFIX}cudnn${_POSTFIX}"
      INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  endif()
  return() #Only cudnn as library
  
elseif(_CUDNN_VERSION_MAJOR EQUAL 8)
  list(APPEND _COMPONENTS 
    cudnn_adv_infer cudnn_adv_train
    cudnn_cnn_infer cudnn_cnn_train
    cudnn_ops_infer cudnn_ops_train
  )

elseif(_CUDNN_VERSION_MAJOR EQUAL 9)
  list(APPEND _COMPONENTS 
    cudnn_adv
    cudnn_cnn
    cudnn_ops
    cudnn_graph
    cudnn_heuristic
    cudnn_engines_precompiled
    cudnn_engines_runtime_compiled
  )
else()
  message(FATAL_ERROR "Unknown version provided")
endif()

foreach(component ${_COMPONENTS})
  if (WIN32)
    find_file(_DLL NAME "${component}64_${_CUDNN_VERSION_MAJOR}.dll"
      HINTS "${CUDNN_INCLUDE_DIR}/../bin" "${CUDNN_INCLUDE_DIR}/../../bin/${_CUDA_VERSION}"
    )

    string(REPLACE "cudnn" "CuDNN" target ${component})

    add_library( CuDNN::${target}      SHARED IMPORTED )
    set_target_properties( CuDNN::${target} PROPERTIES
      IMPORTED_LOCATION                 "${_DLL}"
      IMPORTED_IMPLIB                   "${CUDNN_LIBRARIES_DIR}/${component}${_POSTFIX}"
      INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )

    unset(_DLL CACHE)
  elseif (BUILD_SHARED_LIBS)
    add_library( CuDNN::${target}      SHARED IMPORTED )
    set_target_properties( CuDNN::${target} PROPERTIES
      IMPORTED_LOCATION                 "${CUDNN_LIBRARIES_DIR}/${_PREFIX}${component}${_POSTFIX}"
      INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  else()
    add_library( CuDNN::${target}      STATIC IMPORTED )
    set_target_properties( CuDNN::${target} PROPERTIES
      IMPORTED_LOCATION                 "${CUDNN_LIBRARIES_DIR}/${_PREFIX}${component}${_POSTFIX}"
      INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
  endif()
endforeach()

if (WIN32)
  find_file(_DLL NAME "cudnn64_${_CUDNN_VERSION_MAJOR}.dll"
    HINTS "${CUDNN_INCLUDE_DIR}/../bin" "${CUDNN_INCLUDE_DIR}/../../bin/${_CUDA_VERSION}"
  )

  add_library( CuDNN::CuDNN      SHARED IMPORTED )
  set_target_properties( CuDNN::CuDNN PROPERTIES
    IMPORTED_LOCATION                 "${_DLL}"
    IMPORTED_IMPLIB                   "${_CUDNN_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
else() #cudnn has no static lib after major version 8
  add_library( CuDNN::CuDNN      SHARED IMPORTED )
  set_target_properties( CuDNN::CuDNN PROPERTIES
    IMPORTED_LOCATION                 "${CUDNN_LIBRARIES_DIR}/${_PREFIX}cudnn${_POSTFIX}"
    INTERFACE_INCLUDE_DIRECTORIES     "${CUDNN_INCLUDE_DIR}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
endif()

### Library dependencies ###
if(_CUDNN_VERSION_MAJOR EQUAL 8)

  #https://docs.nvidia.com/deeplearning/cudnn/archives/cudnn-850/api/index.html
  target_link_libraries(CuDNN::CuDNN INTERFACE
    CuDNN::CuDNN_adv_infer CuDNN::CuDNN_adv_train
    CuDNN::CuDNN_cnn_infer CuDNN::CuDNN_cnn_train
    CuDNN::CuDNN_ops_infer CuDNN::CuDNN_ops_train
  )

  target_link_libraries(CuDNN::CuDNN_ops_train INTERFACE
    CuDNN::CuDNN_ops_infer
  )

  target_link_libraries(CuDNN::CuDNN_cnn_infer INTERFACE
    CuDNN::CuDNN_ops_infer
  )

  target_link_libraries(CuDNN::CuDNN_cnn_train INTERFACE
    CuDNN::CuDNN_ops_infer CuDNN::CuDNN_ops_train
    CuDNN::CuDNN_cnn_infer
  )

  target_link_libraries(CuDNN::CuDNN_adv_infer INTERFACE
    CuDNN::CuDNN_ops_infer
  )

  target_link_libraries(CuDNN::CuDNN_adv_train INTERFACE
    CuDNN::CuDNN_ops_infer CuDNN::CuDNN_ops_train
    CuDNN::CuDNN_adv_infer
  )

elseif(_CUDNN_VERSION_MAJOR EQUAL 9)

  #https://docs.nvidia.com/deeplearning/cudnn/v9.4.0/api/overview.html
  target_link_libraries(CuDNN::CuDNN INTERFACE
    CuDNN::CuDNN_cnn CuDNN::CuDNN_ops CuDNN::CuDNN_adv CuDNN::CuDNN_graph
  )
  target_link_libraries(CuDNN::CuDNN_cnn INTERFACE
    CuDNN::CuDNN_ops CuDNN::CuDNN_graph
  )
  target_link_libraries(CuDNN::CuDNN_ops INTERFACE
    CuDNN::CuDNN_graph
  )
  target_link_libraries(CuDNN::CuDNN_adv INTERFACE
    CuDNN::CuDNN_ops CuDNN::CuDNN_graph
  )
  target_link_libraries(CuDNN::CuDNN_graph INTERFACE
    CuDNN::CuDNN_engines_precompiled CuDNN::CuDNN_heuristic CuDNN::CuDNN_engines_runtime_compiled
  )
  target_link_libraries(CuDNN::CuDNN_engines_precompiled INTERFACE
    CuDNN::CuDNN_graph
  )
  target_link_libraries(CuDNN::CuDNN_heuristic INTERFACE
    CuDNN::CuDNN_graph
  )
  target_link_libraries(CuDNN::CuDNN_engines_runtime_compiled INTERFACE
    CuDNN::CuDNN_graph
  )
endif()