_find_package(PThreads4W)
set(pthreads_INCLUDE_DIR "${PThreads4W_INCLUDE_DIR}")
set(pthreads_LIBRARY "${PThreads4W_LIBRARY}")
set(pthreads_LIBRARIES "${PThreads4W_LIBRARY}")
set(pthreads_VERSION "${PThreads4W_VERSION}")

if(PThreads4W_FOUND)
  set(pthreads_FOUND TRUE)

  if(NOT TARGET PThreads_windows::PThreads_windows)
    if( EXISTS "${PThreads4W_LIBRARY_RELEASE_DLL}" )
      add_library( PThreads_windows::PThreads_windows      SHARED IMPORTED )
      set_target_properties( PThreads_windows::PThreads_windows PROPERTIES
        IMPORTED_LOCATION_RELEASE         "${PThreads4W_LIBRARY_RELEASE_DLL}"
        IMPORTED_IMPLIB                   "${PThreads4W_LIBRARY_RELEASE}"
        INTERFACE_INCLUDE_DIRECTORIES     "${PThreads4W_INCLUDE_DIR}"
        IMPORTED_CONFIGURATIONS           Release
        IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
      if( EXISTS "${PThreads4W_LIBRARY_DEBUG_DLL}" )
        set_property( TARGET PThreads_windows::PThreads_windows APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
        set_target_properties( PThreads_windows::PThreads_windows PROPERTIES
          IMPORTED_LOCATION_DEBUG           "${PThreads4W_LIBRARY_DEBUG_DLL}"
          IMPORTED_IMPLIB_DEBUG             "${PThreads4W_LIBRARY_DEBUG}" )
      endif()
    else()
      add_library( PThreads_windows::PThreads_windows      UNKNOWN IMPORTED )
      set_target_properties( PThreads_windows::PThreads_windows PROPERTIES
        IMPORTED_LOCATION_RELEASE         "${PThreads4W_LIBRARY_RELEASE}"
        INTERFACE_INCLUDE_DIRECTORIES     "${PThreads4W_INCLUDE_DIR}"
        IMPORTED_CONFIGURATIONS           Release
        IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
      if( EXISTS "${PThreads4W_LIBRARY_DEBUG}" )
        set_property( TARGET PThreads_windows::PThreads_windows APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
        set_target_properties( PThreads_windows::PThreads_windows PROPERTIES
          IMPORTED_LOCATION_DEBUG           "${PThreads4W_LIBRARY_DEBUG}" )
      endif()
    endif()
  endif()
endif()
