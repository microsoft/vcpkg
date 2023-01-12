if(NOT TARGET unofficial::chakracore::chakracore)
  add_library(unofficial::chakracore::chakracore UNKNOWN IMPORTED)

  find_path(ChakraCore_INCLUDE_DIR NAMES ChakraCore.h)

  set_target_properties(unofficial::chakracore::chakracore PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${ChakraCore_INCLUDE_DIR}"
  )

  find_library(ChakraCore_LIBRARY_RELEASE NAMES ChakraCore PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib" NO_DEFAULT_PATH REQUIRED)
  find_library(ChakraCore_LIBRARY_DEBUG NAMES ChakraCore PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib" NO_DEFAULT_PATH REQUIRED)

  set_target_properties(unofficial::chakracore::chakracore PROPERTIES
    IMPORTED_LOCATION_DEBUG "${ChakraCore_LIBRARY_DEBUG}"
    IMPORTED_LOCATION_RELEASE "${ChakraCore_LIBRARY_RELEASE}"
    IMPORTED_CONFIGURATIONS "Release;Debug"
  )
endif()
