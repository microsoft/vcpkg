# lcms2-config-shared.cmake — installed on Windows DLL (dynamic) builds only.
# portfile.cmake installs this file renamed to lcms2-config.cmake.
#
# Declares lcms2::lcms2 as SHARED IMPORTED so that:
#   - IMPORTED_IMPLIB_*   carries the import library (.lib) for linking
#   - IMPORTED_LOCATION_* carries the runtime DLL for staging
#
# This is required for CMake's TARGET_RUNTIME_DLLS generator expression to
# propagate the DLL to consumers so it can be copied next to the executable.
if(NOT TARGET lcms2::lcms2)
	get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
	get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
	get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

	add_library(lcms2::lcms2 SHARED IMPORTED)

	set_target_properties(lcms2::lcms2 PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
		MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
		MAP_IMPORTED_CONFIG_MINSIZEREL     Release
	)

	find_library(LCMS2_LIBRARY_DEBUG NAMES lcms2 PATHS "${_IMPORT_PREFIX}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
	if(EXISTS "${LCMS2_LIBRARY_DEBUG}")
		set_property(TARGET lcms2::lcms2 APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
		set_target_properties(lcms2::lcms2 PROPERTIES
			IMPORTED_IMPLIB_DEBUG   "${LCMS2_LIBRARY_DEBUG}"
			IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/lcms2-2.dll"
		)
	endif()

	find_library(LCMS2_LIBRARY_RELEASE NAMES lcms2 PATHS "${_IMPORT_PREFIX}/" PATH_SUFFIXES lib NO_DEFAULT_PATH)
	if(EXISTS "${LCMS2_LIBRARY_RELEASE}")
		set_property(TARGET lcms2::lcms2 APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
		set_target_properties(lcms2::lcms2 PROPERTIES
			IMPORTED_IMPLIB_RELEASE   "${LCMS2_LIBRARY_RELEASE}"
			IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/lcms2-2.dll"
		)
	endif()

	unset(_IMPORT_PREFIX)
endif()
