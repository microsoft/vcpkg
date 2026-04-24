# Compute the installation prefix relative to this file.
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")
  set(_IMPORT_PREFIX "")
endif()

add_library(onnxruntime-cuda12::onnxruntime SHARED IMPORTED)
set_target_properties(onnxruntime-cuda12::onnxruntime PROPERTIES 
    IMPORTED_CONFIGURATIONS RELEASE
    IMPORTED_CONFIGURATIONS DEBUG
    INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include/onnxruntime"
    IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
    IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
)

function(import_providers provider_name)
    message("import provider ${provider_name}")
    add_library(onnxruntime-cuda12::onnxruntime_providers_${provider_name} MODULE IMPORTED)
    set_target_properties(onnxruntime-cuda12::onnxruntime_providers_${provider_name} PROPERTIES 
      IMPORTED_CONFIGURATIONS RELEASE
      IMPORTED_CONFIGURATIONS DEBUG
      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include/onnxruntime"
      IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
      IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
    )
endfunction(import_providers)