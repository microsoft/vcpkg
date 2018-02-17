set(BREAKPAD_FOUND TRUE)

# Compute the installation prefix relative to this file.
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")
  set(_IMPORT_PREFIX "")
endif()

# Create imported target breakpad
set(BREAKPAD_LIBRARIES crash_generation_client common exception_handler processor_bits)
foreach(lib ${BREAKPAD_LIBRARIES})
    add_library(${lib} STATIC IMPORTED)
    set_target_properties(${lib} PROPERTIES
        IMPORTED_CONFIGURATIONS "Debug;Release"
        IMPORTED_LOCATION "${_IMPORT_PREFIX}/lib"
        IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/${lib}.lib"
        IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/${lib}.lib"
    )
endforeach()

set(BREAKPAD_INCLUDE_DIR "${_IMPORT_PREFIX}/include/breakpad")

# Cleanup temporary variables.
set(_IMPORT_PREFIX)