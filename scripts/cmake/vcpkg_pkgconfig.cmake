## # vcpkg_pkgconfig
##
## Uses pkg-config executable in order to retrieve usefull linkage info.
## This is may be usefull in order to build tools for static build versions
##
## ## Usage
## ```cmake
## vcpkg_pkgconfig([APPEND] [AS_STRING] SYSTEM_LIBS_REL <slr> PACKAGE_LIBS_REL <plr> SYSTEM_LIBS_DBG <sld> PACKAGE_LIBS_DBG <pld>
##     PACKAGES <packages>...
## )
## ```
##
## ## Options
## ### APPEND
## libraries are added to the provided "output variables" otherwise (default) those variables are erased first
##
## ### AS_STRING
## libraries are provided as a space separated string otherwise (default) they are provided as a list (semicolon separated)
##
## ## Parameters
## ### SYSTEM_LIBS_REL
## An out-list-variable which will be appended with the release build system libs needed for linking when using a given package.
##
## ### SYSTEM_LIBS_DBG
## An out-list-variable which will be appended with the debug build package libs needed for linking when using a given package.
##
## ### PACKAGE_LIBS_REL
## An out-list-variable which will be appended with the release build system libs needed for linking when using a given package.
##
## ### PACKAGE_LIBS_DBG
## An out-list-variable which will be appended with the debug build package libs needed for linking when using a given package.
##
## ### PACKAGES
## A list of packages to search for dependencies
##
## ## Examples
##


function(vcpkg_pkgconfig)
	cmake_parse_arguments(_pkc "APPEND;AS_STRING" "SYSTEM_LIBS_REL;PACKAGE_LIBS_REL;SYSTEM_LIBS_DBG;PACKAGE_LIBS_DBG" "PACKAGES" ${ARGN})

	if (_pkc_APPEND)
		set(PACKAGE_LIBS_REL ${${_pkc_PACKAGE_LIBS_REL}})
		set(SYSTEM_LIBS_REL ${${_pkc_SYSTEM_LIBS_REL}})
		set(PACKAGE_LIBS_DBG ${${_pkc_PACKAGE_LIBS_DBG}})
		set(SYSTEM_LIBS_DBG ${${_pkc_SYSTEM_LIBS_DBG}})
	else()
		set(PACKAGE_LIBS_REL "")
		set(SYSTEM_LIBS_REL "")
		set(PACKAGE_LIBS_DBG "")
		set(SYSTEM_LIBS_DBG "")	
	endif()
	
	#Search for pkg-config executable
	if (VCPKG_TARGET_IS_WINDOWS)
		vcpkg_acquire_msys(MSYS_ROOT)
		set(PKGCONFIG ${MSYS_ROOT}/usr/bin/pkg-config.exe)
	elseif (VCPKG_TARGET_IS_LINUX)
		set(PKGCONFIG pkg-config)
	endif()

	macro(_pkc_list_files result curdir)
	  file(GLOB children RELATIVE ${curdir} ${curdir}/*.pc)
	  set(dirlist "")
	  foreach(child ${children})
		if(NOT IS_DIRECTORY ${curdir}/${child})
		  list(APPEND dirlist ${child})
		endif()
	  endforeach()
	  set(${result} ${dirlist})
	endmacro()
			
	set(_pkc_possible_build_types "debug;release")
	foreach(_pkc_bt ${_pkc_possible_build_types})
	
		#message(STATUS "build_type ${_pkc_bt}")
	
		set(_pkc_path_extra_subdir "")
	
		if (${_pkc_bt} STREQUAL "release")
			set(_pkc_pkgconfig_output_buildsuffix "rel")
			_pkc_list_files(_pkc_ipl ${CURRENT_INSTALLED_DIR}/lib/pkgconfig)
			#message(STATUS "possibles packages ${_pkc_ipl}")			
		elseif(${_pkc_bt} STREQUAL "debug")
			set(_pkc_pkgconfig_output_buildsuffix "dbg")
			set(_pkc_path_extra_subdir "/debug")
			_pkc_list_files(_pkc_ipl ${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig)
			#message(STATUS "possibles packages ${_pkc_ipl}")			
		else()
			message(FATAL_ERROR "BUILD_TYPE argument should be either release or debug")
		endif()
			
		foreach(_pkc_package ${_pkc_PACKAGES})
			message(STATUS "reading pkg-config output for package ${_pkc_package}")

			#build output filenames
			set(_PKGCONFIG_OTHERLIBS_FILE "pkgconfig-${_pkc_package}-onlyother-${TARGET_TRIPLET}-${_pkc_pkgconfig_output_buildsuffix}")
			set(_PKGCONFIG_SYSTEMLIBS_FILE "pkgconfig-${_pkc_package}-onlyl-${TARGET_TRIPLET}-${_pkc_pkgconfig_output_buildsuffix}")
		
			message(STATUS "output file will be : ${_PKGCONFIG_OTHERLIBS_FILE}")
			message(STATUS "output file will be : ${_PKGCONFIG_SYSTEMLIBS_FILE}")
			
			#search package configuration file
			set(_pkc_pkgconfig_file_found FALSE)
			if ("${_pkc_package}.pc" IN_LIST _pkc_ipl)
				set(_pkc_pkgconfig_file "${_pkc_package}.pc")
				set(_pkc_pkgconfig_file_found TRUE)
			elseif("lib${_pkc_package}.pc" IN_LIST _pkc_ipl)
				set(_pkc_pkgconfig_file "lib${_pkc_package}.pc")
				set(_pkc_pkgconfig_file_found TRUE)
			else()
				foreach(cf ${_pkc_ipl})
					if (NOT _pkc_pkgconfig_file_found)
						set(_possible_search_strings "lib${_pkc_package};${_pkc_package}")
						foreach(_pss ${_possible_search_strings})
							if (NOT _pkc_pkgconfig_file_found)
								string(FIND "${cf}" ${_pss} _tmp_res)
								if (NOT (${_tmp_res} EQUAL -1))
									set(_pkc_pkgconfig_file "${cf}")
									set(_pkc_pkgconfig_file_found TRUE)
								endif()
							else()
								break()
							endif()
						endforeach()
					else()
						break()
					endif()
				endforeach()
			endif()
			
			if (NOT _pkc_pkgconfig_file_found)	
				message(FATAL_ERROR "No suitable configuration information file was found for ${_pkc_package}")
			else()
				message(STATUS "config file for ${_pkc_package} is ${_pkc_pkgconfig_file}")
			endif()
			
			# Execute pkg-config commands to retrieve -l format and full path format libs separatly
			message(STATUS "running ${PKGCONFIG} --libs-only-other ${CURRENT_INSTALLED_DIR}${_pkc_path_extra_subdir}/lib/pkgconfig/${_pkc_pkgconfig_file}")
			vcpkg_execute_required_process(COMMAND ${PKGCONFIG} --libs-only-other ${CURRENT_INSTALLED_DIR}${_pkc_path_extra_subdir}/lib/pkgconfig/${_pkc_pkgconfig_file}
										   WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
										   LOGNAME "${_PKGCONFIG_OTHERLIBS_FILE}")

			message(STATUS "running ${PKGCONFIG} --libs-only-l ${CURRENT_INSTALLED_DIR}${_pkc_path_extra_subdir}/lib/pkgconfig/${_pkc_pkgconfig_file}")
			vcpkg_execute_required_process(COMMAND ${PKGCONFIG} --libs-only-l ${CURRENT_INSTALLED_DIR}${_pkc_path_extra_subdir}/lib/pkgconfig/${_pkc_pkgconfig_file}
										   WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
										   LOGNAME "${_PKGCONFIG_SYSTEMLIBS_FILE}")
					
			#re-read output files in order to process/format the libs change strings to lists
			file(STRINGS "${CURRENT_BUILDTREES_DIR}/${_PKGCONFIG_OTHERLIBS_FILE}-out.log" _pkc_PKGCONFIG_OTHERLIBS)
			string(REPLACE " " ";" _pkc_PKGCONFIG_OTHERLIBS "${_pkc_PKGCONFIG_OTHERLIBS}")
			
			file(STRINGS "${CURRENT_BUILDTREES_DIR}/${_PKGCONFIG_SYSTEMLIBS_FILE}-out.log" _pkc_PKGCONFIG_SYSTEMLIBS)
			string(REPLACE " " ";" _pkc_PKGCONFIG_SYSTEMLIBS "${_pkc_PKGCONFIG_SYSTEMLIBS}")
			
			#Process/check libs and add to the output
			# for package libs (full path format) : simply check if file exists and is not already in list
			foreach(_pkc_elem ${_pkc_PKGCONFIG_OTHERLIBS})
				if(EXISTS ${_pkc_elem} AND NOT IS_DIRECTORY ${_pkc_elem})
					#message(STATUS "adding ${_pkc_elem}")
					if (${_pkc_bt} STREQUAL "release")
						if (NOT ${_pkc_elem} IN_LIST PACKAGE_LIBS_REL)
							list(APPEND PACKAGE_LIBS_REL ${_pkc_elem})
						endif()
					elseif (${_pkc_bt} STREQUAL "debug")
						if (NOT ${_pkc_elem} IN_LIST PACKAGE_LIBS_DBG)
							list(APPEND PACKAGE_LIBS_DBG ${_pkc_elem})
						endif()
					endif()
				endif()
			endforeach()

			# for system libs (-l format)
			foreach(_pkc_elem ${_pkc_PKGCONFIG_SYSTEMLIBS})
				string(REPLACE "-l" "" _pkc_elem "${_pkc_elem}")
				if (${_pkc_elem} IN_LIST VCPKG_SYSTEM_LIBRARIES)
					if (VCPKG_TARGET_IS_WINDOWS)
						string(APPEND _pkc_elem "${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}")
						set(_do_append TRUE)
					else()
						set(_do_append FALSE)
					endif()
				else()
					list(LENGTH VCPKG_FIND_LIBRARY_PREFIXES _pkc_possible_lib_prefix_count)
					list(LENGTH VCPKG_FIND_LIBRARY_SUFFIXES _pkc_possible_lib_suffix_count)
					math(EXPR _pkc_possible_lib_prefix_count "${_pkc_possible_lib_prefix_count} - 1")
					math(EXPR _pkc_possible_lib_suffix_count "${_pkc_possible_lib_suffix_count} - 1")					
					foreach(indexp RANGE 0 ${_pkc_possible_lib_prefix_count})
						foreach(indexs RANGE 0 ${_pkc_possible_lib_suffix_count})
							list(GET VCPKG_FIND_LIBRARY_PREFIXES ${indexp} _pr)
							list(GET VCPKG_FIND_LIBRARY_SUFFIXES ${indexs} _su)
							set(_test_lib_file "${CURRENT_INSTALLED_DIR}${_pkc_path_extra_subdir}/lib/${_pr}${_pkc_elem}${_su}")
							if (EXISTS ${_test_lib_file} AND NOT IS_DIRECTORY ${_test_lib_file})
								set(_pkc_elem ${_test_lib_file})
								set(_do_append TRUE)
								break()
							else()
								set(_do_append FALSE)
							endif()
						endforeach()
						if (_do_append)
							break()
						endif()
					endforeach()
					
				endif()
				
				if (${_pkc_bt} STREQUAL "release" AND _do_append)
					list(APPEND SYSTEM_LIBS_REL ${_pkc_elem})
				elseif (${_pkc_bt} STREQUAL "debug" AND _do_append)
					list(APPEND SYSTEM_LIBS_DBG ${_pkc_elem})
				endif()
			endforeach()
			
		endforeach()
	endforeach()
	
	#Output for calling function
	if (_pkc_AS_STRING)
		string(REPLACE ";" " " PACKAGE_LIBS_REL "${PACKAGE_LIBS_REL}")
		string(REPLACE ";" " " SYSTEM_LIBS_REL "${SYSTEM_LIBS_REL}")
		string(REPLACE ";" " " PACKAGE_LIBS_DBG "${PACKAGE_LIBS_DBG}")
		string(REPLACE ";" " " SYSTEM_LIBS_DBG "${SYSTEM_LIBS_DBG}")		
	endif()
	
	set(${_pkc_PACKAGE_LIBS_REL} "${PACKAGE_LIBS_REL}" PARENT_SCOPE)
	set(${_pkc_SYSTEM_LIBS_REL} "${SYSTEM_LIBS_REL}" PARENT_SCOPE)
	set(${_pkc_PACKAGE_LIBS_DBG} "${PACKAGE_LIBS_DBG}" PARENT_SCOPE)
	set(${_pkc_SYSTEM_LIBS_DBG} "${SYSTEM_LIBS_DBG}" PARENT_SCOPE)
				
endfunction()
