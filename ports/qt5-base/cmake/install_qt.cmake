include(qt_fix_makefile_install)

function(install_qt)
    cmake_parse_arguments(_bc "DISABLE_PARALLEL" "" "" ${ARGN})

    if (_bc_DISABLE_PARALLEL)
        set(NUMBER_OF_PROCESSORS "1")
    else()
        if(DEFINED ENV{NUMBER_OF_PROCESSORS})
            set(NUMBER_OF_PROCESSORS $ENV{NUMBER_OF_PROCESSORS})
        elseif(VCPKG_TARGET_IS_OSX)
            execute_process(
                COMMAND sysctl -n hw.ncpu
                OUTPUT_VARIABLE NUMBER_OF_PROCESSORS
            )
            string(REPLACE "\n" "" NUMBER_OF_PROCESSORS "${NUMBER_OF_PROCESSORS}")
            string(REPLACE " " "" NUMBER_OF_PROCESSORS "${NUMBER_OF_PROCESSORS}")
        else()
            execute_process(
                COMMAND nproc
                OUTPUT_VARIABLE NUMBER_OF_PROCESSORS
            )
            string(REPLACE "\n" "" NUMBER_OF_PROCESSORS "${NUMBER_OF_PROCESSORS}")
            string(REPLACE " " "" NUMBER_OF_PROCESSORS "${NUMBER_OF_PROCESSORS}")
        endif()
    endif()

    message(STATUS "NUMBER_OF_PROCESSORS is ${NUMBER_OF_PROCESSORS}")

    if(CMAKE_HOST_WIN32)
        vcpkg_find_acquire_program(JOM)
        set(INVOKE "${JOM}" /J ${NUMBER_OF_PROCESSORS})
    else()
        find_program(MAKE make)
        set(INVOKE "${MAKE}" -j${NUMBER_OF_PROCESSORS})
        set(INVOKE_SINGLE "${MAKE}" -j1)
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

    #Replace with VCPKG variables if PR #7733 is merged
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
        
        vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}${_path_suffix_${_buildname}}/bin")

        if(VCPKG_TARGET_IS_OSX)
           # For some reason there will be an error on MacOSX without this clean!
            message(STATUS "Cleaning before build ${_build_triplet}")
            vcpkg_execute_required_process(
                COMMAND ${INVOKE_SINGLE} clean
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}
                LOGNAME cleaning-1-${_build_triplet}
            )
        endif()
        
        message(STATUS "Building ${_build_triplet}")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}
            LOGNAME build-${_build_triplet}
        )
        
        if(VCPKG_TARGET_IS_OSX)
           # For some reason there will be an error on MacOSX without this clean!
            message(STATUS "Cleaning after build before install ${_build_triplet}")
            vcpkg_execute_required_process(
                COMMAND ${INVOKE_SINGLE} clean
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}
                LOGNAME cleaning-2-${_build_triplet}
            )
        endif()
        
        message(STATUS "Fixing makefile installation path ${_build_triplet}")
        qt_fix_makefile_install("${CURRENT_BUILDTREES_DIR}/${_build_triplet}")
        message(STATUS "Installing ${_build_triplet}")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE} install
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}
            LOGNAME package-${_build_triplet}
        )
        message(STATUS "Package ${_build_triplet} done")
        set(ENV{PATH} "${_path}")
    endforeach()
    

    
endfunction()
