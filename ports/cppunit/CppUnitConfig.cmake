
include(SelectLibraryConfigurations)

find_path(CppUnit_INCLUDE_DIR TestCase.h PATH_SUFFIXES cppunit)
find_library(CppUnit_LIBRARY_RELEASE NAMES cppunit PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib" NO_DEFAULT_PATH)
find_library(CppUnit_LIBRARY_DEBUG NAMES cppunitd cppunit PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib" NO_DEFAULT_PATH)
select_library_configurations(CppUnit)

if(NOT CppUnit_LIBRARY)
  set(CppUnit_FOUND FALSE)
  set(CPPUNIT_FOUND FALSE)
  return()
endif()

if(WIN32)
  find_file(CppUnit_LIBRARY_RELEASE_DLL NAMES cppunit.dll PATHS "${CMAKE_CURRENT_LIST_DIR}/../../bin" NO_DEFAULT_PATH)
  find_file(CppUnit_LIBRARY_DEBUG_DLL NAMES cppunitd.dll PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/bin" NO_DEFAULT_PATH)
endif()

# Manage Release Windows shared
if(EXISTS "${CppUnit_LIBRARY_RELEASE_DLL}")
  add_library(CppUnit SHARED IMPORTED)
  set_target_properties(CppUnit PROPERTIES
    IMPORTED_CONFIGURATIONS Release
    IMPORTED_LOCATION_RELEASE "${CppUnit_LIBRARY_RELEASE_DLL}"
    IMPORTED_IMPLIB_RELEASE "${CppUnit_LIBRARY_RELEASE}"
    INTERFACE_INCLUDE_DIRECTORIES "${CppUnit_INCLUDE_DIR}"
  )
endif()

# Manage Debug Windows shared
if(EXISTS "${CppUnit_LIBRARY_DEBUG_DLL}")
  if(EXISTS "${CppUnit_LIBRARY_RELEASE_DLL}")
    set_target_properties(CppUnit PROPERTIES
      IMPORTED_CONFIGURATIONS "Release;Debug"
      IMPORTED_LOCATION_RELEASE "${CppUnit_LIBRARY_RELEASE_DLL}"
      IMPORTED_IMPLIB_RELEASE "${CppUnit_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${CppUnit_LIBRARY_DEBUG_DLL}"
      IMPORTED_IMPLIB_DEBUG "${CppUnit_LIBRARY_DEBUG}"
      INTERFACE_INCLUDE_DIRECTORIES "${CppUnit_INCLUDE_DIR}"    
    )
  else()  
    add_library(CppUnit SHARED IMPORTED)
    set_target_properties(CppUnit PROPERTIES
      IMPORTED_CONFIGURATIONS Debug
      IMPORTED_LOCATION_DEBUG "${CppUnit_LIBRARY_DEBUG_DLL"
      IMPORTED_IMPLIB_DEBUG "${CppUnit_LIBRARY_DEBUG}"
      INTERFACE_INCLUDE_DIRECTORIES "${CppUnit_INCLUDE_DIR}"
    )
  endif()
endif()

# Manage Release Windows static and Linux shared/static
if((NOT EXISTS "${CppUnit_LIBRARY_RELEASE_DLL}") AND (EXISTS "${CppUnit_LIBRARY_RELEASE}"))
  add_library(CppUnit UNKNOWN IMPORTED)
  set_target_properties(CppUnit PROPERTIES
    IMPORTED_CONFIGURATIONS Release
    IMPORTED_LOCATION_RELEASE "${CppUnit_LIBRARY_RELEASE}"
    INTERFACE_INCLUDE_DIRECTORIES "${CppUnit_INCLUDE_DIR}"
  )
endif()

# Manage Debug Windows static and Linux shared/static
if((NOT EXISTS "${CppUnit_LIBRARY_DEBUG_DLL}") AND (EXISTS "${CppUnit_LIBRARY_DEBUG}"))
  if(EXISTS "${CppUnit_LIBRARY_RELEASE}")
    set_target_properties(CppUnit PROPERTIES
      IMPORTED_CONFIGURATIONS "Release;Debug"
      IMPORTED_LOCATION_RELEASE "${CppUnit_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${CppUnit_LIBRARY_DEBUG}"
      INTERFACE_INCLUDE_DIRECTORIES "${CppUnit_INCLUDE_DIR}"   
    )
  else()
    add_library(CppUnit UNKNOWN IMPORTED)
    set_target_properties(CppUnit PROPERTIES
      IMPORTED_CONFIGURATIONS Debug
      IMPORTED_LOCATION_DEBUG "${CppUnit_LIBRARY_DEBUG}"
      INTERFACE_INCLUDE_DIRECTORIES "${CppUnit_INCLUDE_DIR}"
    )
  endif()
endif()

set(CppUnit_FOUND TRUE)
set(CPPUNIT_FOUND TRUE)