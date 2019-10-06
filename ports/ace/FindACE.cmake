set(ACE_FOUND FALSE)

find_path(ACE_INCLUDE_DIR ace/ACE.h PATHS $ENV{ACE_ROOT} $ENV{ACE_ROOT}/include /usr/include /usr/local/include NO_DEFAULT_PATH)
find_library(ACE_LIBRARY_RELEASE NAMES ACE PATHS $ENV{ACE_ROOT}/lib /usr/lib /usr/lib64 /usr/local/lib /usr/local/lib64 NO_DEFAULT_PATH)
find_library(ACE_LIBRARY_DEBUG NAMES ACEd PATHS $ENV{ACE_ROOT}/lib /debug/lib /usr/lib /usr/lib64 /usr/local/lib /usr/local/lib64 NO_DEFAULT_PATH)


if(ACE_INCLUDE_DIR AND ACE_LIBRARY_RELEASE)
  SET(ACE_FOUND TRUE)
endif(ACE_INCLUDE_DIR AND ACE_LIBRARY_RELEASE)
#now let's search for parts of ACE we need.

GET_FILENAME_COMPONENT(ACE_LIBRARY_RELEASE_DIR ${ACE_LIBRARY_RELEASE} PATH)
GET_FILENAME_COMPONENT(ACE_LIBRARY_DEBUG_DIR ${ACE_LIBRARY_DEBUG} PATH)

set(ACE_LIBRARIES_RELEASE ${ACE_LIBRARY_RELEASE})
set(ACE_LIBRARIES_DEBUG ${ACE_LIBRARY_DEBUG})

if(ACE_FOUND)
	set(ACE_FIND_LIBS "ACE" "Compression" "ETCL" "ETCL_Parser" "HTBP" "INet" "INet_SSL"
    "Monitor_Control" "QoS" "QtReactor" "RLECompression" "RMCast" "SSL" 
    "TMCast" "ACEXML" "ACEXML_Parser" "Kokyu")
    	
    message("Finding ACE libraries...")
	
	if(WIN32)
		message(STATUS "ACE release found at: ${ACE_LIBRARY_RELEASE}")
		message(STATUS "ACE debug found at: ${ACE_LIBRARY_DEBUG}")
		set(ACE_LIBRARY optimized ${ACE_LIBRARY_RELEASE} debug ${ACE_LIBRARY_DEBUG})
	else(WIN32)
		message(STATUS "ACE found at: ${ACE_LIBRARY_RELEASE}")
		set(ACE_LIBRARY ${ACE_LIBRARY_RELEASE})
	endif(WIN32)
	
    foreach(LIBRARY ${ACE_FIND_LIBS})	
		if(WIN32)
			find_library(ACE_${LIBRARY}_LIBRARY_DEBUG NAMES "ACE_${LIBRARY}d" "ACE${LIBRARY}d" "${LIBRARY}d" PATHS ${ACE_LIBRARY_DEBUG_DIR} NO_DEFAULT_PATH)
			if(ACE_${LIBRARY}_LIBRARY_DEBUG)
				message(STATUS "${LIBRARY} debug found at: ${ACE_${LIBRARY}_LIBRARY_DEBUG}")
				list(APPEND ACE_LIBRARIES_DEBUG ${ACE_${LIBRARY}_LIBRARY_DEBUG})
			else(ACE_${LIBRARY}_LIBRARY_DEBUG)
				set(ACE_FOUND FALSE)
			endif(ACE_${LIBRARY}_LIBRARY_DEBUG)
		endif(WIN32)

        find_library(ACE_${LIBRARY}_LIBRARY_RELEASE NAMES "ACE_${LIBRARY}" "ACE${LIBRARY}" "${LIBRARY}" PATHS ${ACE_LIBRARY_RELEASE_DIR} NO_DEFAULT_PATH)
        if(ACE_${LIBRARY}_LIBRARY_RELEASE)
			if(WIN32)
				message(STATUS "${LIBRARY} release found at: ${ACE_${LIBRARY}_LIBRARY_RELEASE}")
			else(WIN32)
				message(STATUS "${LIBRARY} found at: ${ACE_${LIBRARY}_LIBRARY_RELEASE}")
			endif(WIN32)
			list(APPEND ACE_LIBRARIES_RELEASE ${ACE_${LIBRARY}_LIBRARY_RELEASE})
        else(ACE_${LIBRARY}_LIBRARY_RELEASE)
			set(ACE_FOUND FALSE)
        endif(ACE_${LIBRARY}_LIBRARY_RELEASE)

		if(WIN32)
			set(ACE_${LIBRARY}_LIBRARY optimized ${ACE_${LIBRARY}_LIBRARY_RELEASE} debug ${ACE_${LIBRARY}_LIBRARY_DEBUG})
		else(WIN32)
			set(ACE_${LIBRARY}_LIBRARY ${ACE_${LIBRARY}_LIBRARY_RELEASE})
		endif(WIN32)
    endforeach()
endif(ACE_FOUND)


