set(CppWinRT_FOUND TRUE)

if(NOT TARGET Microsoft::CppWinRT)
   get_filename_component(cppwinrt_root "${CMAKE_CURRENT_LIST_DIR}" PATH)
   get_filename_component(cppwinrt_root "${cppwinrt_root}" PATH)

   add_library(Microsoft::CppWinRT INTERFACE IMPORTED)
   set_target_properties(Microsoft::CppWinRT PROPERTIES
      INTERFACE_COMPILE_FEATURES cxx_std_17
      INTERFACE_INCLUDE_DIRECTORIES "${cppwinrt_root}/include"
      INTERFACE_LINK_LIBRARIES "${cppwinrt_root}/lib/cppwinrt_fast_forwarder.lib"
   )
   unset(cppwinrt_root)
endif()
