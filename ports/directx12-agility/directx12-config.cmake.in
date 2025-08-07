get_filename_component(_dx12_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_dx12_root "${_dx12_root}" PATH)
get_filename_component(_dx12_root "${_dx12_root}" PATH)

if (EXISTS "${_dx12_root}/bin/D3D12Core.dll")

   find_library(D3D12_LIB NAMES d3d12)

   if("${D3D12_LIB}" STREQUAL "D3D12_LIB-NOTFOUND")
       message(FATAL_ERROR "D3D12.LIB import library from the Windows SDK is required")
   endif()

   add_library(Microsoft::DirectX12-Core SHARED IMPORTED)
   set_target_properties(Microsoft::DirectX12-Core PROPERTIES
      IMPORTED_LOCATION_RELEASE            "${_dx12_root}/bin/D3D12Core.dll"
      IMPORTED_LOCATION_DEBUG              "${_dx12_root}/debug/bin/D3D12Core.dll"
      IMPORTED_IMPLIB                      "${D3D12_LIB}"
      IMPORTED_CONFIGURATIONS              "Debug;Release"
      IMPORTED_LINK_INTERFACE_LANGUAGES    "C")

   add_library(Microsoft::DirectX12-Layers SHARED IMPORTED)
   set_target_properties(Microsoft::DirectX12-Layers PROPERTIES
      IMPORTED_LOCATION_RELEASE            "${_dx12_root}/debug/bin/d3d12SDKLayers.dll"
      IMPORTED_LOCATION_DEBUG              "${_dx12_root}/debug/bin/d3d12SDKLayers.dll"
      IMPORTED_IMPLIB                      "${D3D12_LIB}"
      IMPORTED_CONFIGURATIONS              "Debug;Release"
      IMPORTED_LINK_INTERFACE_LANGUAGES    "C")

   add_library(Microsoft::DirectX12-Agility INTERFACE IMPORTED)
   set_target_properties(Microsoft::DirectX12-Agility PROPERTIES
      INTERFACE_LINK_LIBRARIES "Microsoft::DirectX12-Core;Microsoft::DirectX12-Layers")

    set(directx12-agility_FOUND TRUE)

else()

    set(directx12-agility_FOUND FALSE)

endif()

unset(_dx12_root)
