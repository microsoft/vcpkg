if(NOT TARGET unofficial::livepp::livepp)
     get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
     get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
     get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
     if(_IMPORT_PREFIX STREQUAL "/")
          set(_IMPORT_PREFIX "")
     endif()

     add_library(unofficial::livepp::livepp INTERFACE IMPORTED)
     set_target_properties(unofficial::livepp::livepp PROPERTIES
          INTERFACE_COMPILE_DEFINITIONS VCPKG_LIVEPP_PATH="${_IMPORT_PREFIX}/tools/livepp"
          INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
     )

     unset(_IMPORT_PREFIX)
endif()