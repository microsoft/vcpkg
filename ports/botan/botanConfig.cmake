include(SelectLibraryConfigurations)

find_path(Botan_INCLUDE_DIR "botan/botan.h"
	PATHS "${CMAKE_CURRENT_LIST_DIR}/../../include" NO_DEFAULT_PATH 
)
find_library(Botan_LIBRARY_RELEASE NAMES botan PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib" NO_DEFAULT_PATH)
find_library(Botan_LIBRARY_DEBUG NAMES botand botan PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib" NO_DEFAULT_PATH)
select_library_configurations(Botan)


if(NOT Botan_LIBRARY)
  set(Botan_FOUND FALSE)
  set(BOTAN_FOUND FALSE)
  return()
endif()

if(WIN32)
  find_file(Botan_LIBRARY_RELEASE_DLL NAMES botan.dll PATHS "${CMAKE_CURRENT_LIST_DIR}/../../bin" NO_DEFAULT_PATH)
  find_file(Botan_LIBRARY_DEBUG_DLL NAMES botand.dll botan.dll PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/bin" NO_DEFAULT_PATH)
endif()

# Manage Release Windows shared
if(EXISTS "${Botan_LIBRARY_RELEASE_DLL}")
  add_library(Botan SHARED IMPORTED)
  set_target_properties(Botan PROPERTIES
    IMPORTED_CONFIGURATIONS Release
    IMPORTED_LOCATION_RELEASE "${Botan_LIBRARY_RELEASE_DLL}"
    IMPORTED_IMPLIB_RELEASE "${Botan_LIBRARY_RELEASE}"
    INTERFACE_INCLUDE_DIRECTORIES "${Botan_INCLUDE_DIR}"
  )
endif()

# Manage Debug Windows shared
if(EXISTS "${Botan_LIBRARY_DEBUG_DLL}")
  if(EXISTS "${Botan_LIBRARY_RELEASE_DLL}")
    set_target_properties(Botan PROPERTIES
      IMPORTED_CONFIGURATIONS "Release;Debug"
      IMPORTED_LOCATION_RELEASE "${Botan_LIBRARY_RELEASE_DLL}"
      IMPORTED_IMPLIB_RELEASE "${Botan_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${Botan_LIBRARY_DEBUG_DLL}"
      IMPORTED_IMPLIB_DEBUG "${Botan_LIBRARY_DEBUG}"
      INTERFACE_INCLUDE_DIRECTORIES "${Botan_INCLUDE_DIR}"    
    )
  else()  
    add_library(Botan SHARED IMPORTED)
    set_target_properties(Botan PROPERTIES
      IMPORTED_CONFIGURATIONS Debug
      IMPORTED_LOCATION_DEBUG "${Botan_LIBRARY_DEBUG_DLL"
      IMPORTED_IMPLIB_DEBUG "${Botan_LIBRARY_DEBUG}"
      INTERFACE_INCLUDE_DIRECTORIES "${Botan_INCLUDE_DIR}"
    )
  endif()
endif()

# Manage Release Windows static and Linux shared/static
if((NOT EXISTS "${Botan_LIBRARY_RELEASE_DLL}") AND (EXISTS "${Botan_LIBRARY_RELEASE}"))
  add_library(Botan UNKNOWN IMPORTED)
  set_target_properties(Botan PROPERTIES
    IMPORTED_CONFIGURATIONS Release
    IMPORTED_LOCATION_RELEASE "${Botan_LIBRARY_RELEASE}"
    INTERFACE_INCLUDE_DIRECTORIES "${Botan_INCLUDE_DIR}"
  )
endif()

# Manage Debug Windows static and Linux shared/static
if((NOT EXISTS "${Botan_LIBRARY_DEBUG_DLL}") AND (EXISTS "${Botan_LIBRARY_DEBUG}"))
  if(EXISTS "${Botan_LIBRARY_RELEASE}")
    set_target_properties(Botan PROPERTIES
      IMPORTED_CONFIGURATIONS "Release;Debug"
      IMPORTED_LOCATION_RELEASE "${Botan_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${Botan_LIBRARY_DEBUG}"
      INTERFACE_INCLUDE_DIRECTORIES "${Botan_INCLUDE_DIR}"   
    )
  else()
    add_library(Botan UNKNOWN IMPORTED)
    set_target_properties(Botan PROPERTIES
      IMPORTED_CONFIGURATIONS Debug
      IMPORTED_LOCATION_DEBUG "${Botan_LIBRARY_DEBUG}"
      INTERFACE_INCLUDE_DIRECTORIES "${Botan_INCLUDE_DIR}"
    )
  endif()
endif()

set(Botan_FOUND TRUE)
set(BOTAN_FOUND TRUE)