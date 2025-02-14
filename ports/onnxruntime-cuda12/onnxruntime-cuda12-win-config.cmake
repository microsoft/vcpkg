include("${CMAKE_CURRENT_LIST_DIR}/onnxruntime-cuda12-base-config.cmake")

set_target_properties(onnxruntime-cuda12::onnxruntime PROPERTIES 
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/onnxruntime.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/onnxruntime.dll"
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/onnxruntime.lib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/onnxruntime.dll"
)

foreach(provider IN LISTS shared cuda tensorrt)
  import_providers(${provider})
  set_target_properties(onnxruntime-cuda12::onnxruntime_providers_${provider} PROPERTIES 
    IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/onnxruntime_providers_${provider}.lib"
    IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/onnxruntime_providers_${provider}.dll"
    IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/onnxruntime_providers_${provider}.lib"
    IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/onnxruntime_providers_${provider}.dll"
  )
endforeach()

list(APPEND _cmake_import_check_targets onnxruntime-cuda12::onnxruntime)
list(APPEND _cmake_import_check_files_for_onnxruntime-cuda12::onnxruntime 
  "${_IMPORT_PREFIX}/lib/onnxruntime.lib"
  "${_IMPORT_PREFIX}/bin/onnxruntime.dll"
  "${_IMPORT_PREFIX}/debug/lib/onnxruntime.lib"
  "${_IMPORT_PREFIX}/debug/bin/onnxruntime.dll"
)

foreach(provider IN LISTS shared cuda tensorrt)
  list(APPEND _cmake_import_check_targets onnxruntime-cuda12::onnxruntime_providers_${provider})
  list(APPEND _cmake_import_check_files_for_onnxruntime-cuda12::onnxruntime_providers_${provider} 
    "${_IMPORT_PREFIX}/lib/onnxruntime_providers_${provider}.lib"
    "${_IMPORT_PREFIX}/bin/onnxruntime_providers_${provider}.dll"
    "${_IMPORT_PREFIX}/debug/lib/onnxruntime_providers_${provider}.lib"
    "${_IMPORT_PREFIX}/debug/bin/onnxruntime_providers_${provider}.dll"
  )
endforeach()
