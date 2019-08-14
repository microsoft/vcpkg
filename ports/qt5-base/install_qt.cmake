function(install_qt)
    cmake_parse_arguments(_bc "DISABLE_PARALLEL" "" "" ${ARGN})

    if (_bc_DISABLE_PARALLEL)
        set(NUMBER_OF_PROCESSORS "1")
    else()
        if(DEFINED ENV{NUMBER_OF_PROCESSORS})
            set(NUMBER_OF_PROCESSORS $ENV{NUMBER_OF_PROCESSORS})
        else()
            execute_process(
                COMMAND nproc
                OUTPUT_VARIABLE NUMBER_OF_PROCESSORS
            )
            string(REPLACE "\n" "" NUMBER_OF_PROCESSORS "${NUMBER_OF_PROCESSORS}")
            string(REPLACE " " "" NUMBER_OF_PROCESSORS "${NUMBER_OF_PROCESSORS}")
        endif()
    endif()

    if(CMAKE_HOST_WIN32)
        vcpkg_find_acquire_program(JOM)
        set(INVOKE "${JOM}" /J ${NUMBER_OF_PROCESSORS})
    else()
        find_program(MAKE make)
        set(INVOKE "${MAKE}" -j${NUMBER_OF_PROCESSORS})
    endif()
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

    if (CMAKE_HOST_WIN32)
	# flex and bison for ANGLE library
	vcpkg_find_acquire_program(FLEX)
	get_filename_component(FLEX_EXE_PATH ${FLEX} DIRECTORY)
	get_filename_component(FLEX_DIR ${FLEX_EXE_PATH} NAME)

	file(COPY ${FLEX_EXE_PATH} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-tools" )
	set(FLEX_TEMP "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-tools/${FLEX_DIR}")
	file(RENAME "${FLEX_TEMP}/win_bison.exe" "${FLEX_TEMP}/bison.exe")
	file(RENAME "${FLEX_TEMP}/win_flex.exe" "${FLEX_TEMP}/flex.exe")
	vcpkg_add_to_path("${FLEX_TEMP}")
   endif()

   set(_path "$ENV{PATH}")

    unset(BUILDTYPES)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(_buildname "DEBUG")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "dbg")
        set(_path_suffix_${_buildname} "/debug")
        set(_build_type_${_buildname} "debug")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_buildname "RELEASE")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "rel")
        set(_path_suffix_${_buildname} "")
        set(_build_type_${_buildname} "release")
    endif()
    unset(_buildname)
    
    foreach(_buildname ${BUILDTYPES})
        set(_build_triplet ${TARGET_TRIPLET}-${_short_name_${_buildname}})
        message(STATUS "Package ${_build_triplet}")
        vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}${_path_suffix_${_buildname}}/bin")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}
            LOGNAME build-${_build_triplet}
        )
        vcpkg_execute_required_process(
            COMMAND ${INVOKE} install
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}
            LOGNAME package-${_build_triplet}
        )
        message(STATUS "Package ${_build_triplet} done")
        
        # Copy configuration dependent qt.conf
        file(TO_CMAKE_PATH "${CURRENT_PACKAGES_DIR}" CMAKE_CURRENT_PACKAGES_DIR_PATH)
        file(TO_CMAKE_PATH "${VCPKG_QT_HOST_TOOLS_ROOT_DIR}" CMAKE_VCPKG_QT_HOST_ROOT_PATH)
        file(READ "${CURRENT_BUILDTREES_DIR}/${_build_triplet}/bin/qt.conf" _contents)
        string(REPLACE "${CMAKE_CURRENT_PACKAGES_DIR_PATH}" "\${CURRENT_INSTALLED_DIR}" _contents ${_contents})
        string(REPLACE "[EffectiveSourcePaths]" "" _contents ${_contents})
        string(REGEX REPLACE "[EffectivePaths]\\nPrefix=\.\." "" _contents ${_contents})
        string(REGEX REPLACE "[EffectiveSourcePaths]\\nPrefix=.+$" "" _contents ${_contents})
        file(WRITE "${CURRENT_PACKAGES_DIR}/tools/qt5/qt_${_build_type_${_buildname}}.conf" "${_contents}")     
    endforeach()
    
    set(ENV{PATH} "${_path}")
    
endfunction()
