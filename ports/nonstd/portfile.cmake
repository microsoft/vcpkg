include(vcpkg_common_functions)
include(${CMAKE_CURRENT_LIST_DIR}/nonstd.cmake)

list(LENGTH FEATURES FEATURES_LENGTH)
message("There is : ${FEATURES_LENGTH} features")
# If there is only core, we build all
if (FEATURES_LENGTH EQUAL 1)
	set(
		FEATURES 
			expected
			span
			optional
			variant
			string-view
			byte
			any	
			observer-ptr
		)
endif()

foreach(FEATURE IN LISTS FEATURES)

	# Nothing to do if its core feature
	if (${FEATURE} STREQUAL "core")
		continue()
	endif()

	nonstd_download_and_install(
		NAME ${FEATURE}
	)
	
endforeach()


