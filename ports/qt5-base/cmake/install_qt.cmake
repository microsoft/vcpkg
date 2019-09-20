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
    
    foreach(_buildname ${VCPKG_BUILD_LIST})
        set(_build_triplet ${VCPKG_BUILD_TRIPLET_${_buildname}})
        
        vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}${VCPKG_PATH_SUFFIX_${_buildname}}/bin")

        if(VCPKG_TARGET_IS_OSX)
           # For some reason there will be an error on MacOSX without this clean!
            message(STATUS "Cleaning before build ${_build_triplet}")
            vcpkg_execute_required_process(
                COMMAND ${INVOKE_SINGLE} clean
                WORKING_DIRECTORY ${VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname}}
                LOGNAME cleaning-1-${_build_triplet}
            )
        endif()
        
        message(STATUS "Building ${_build_triplet}")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE}
            WORKING_DIRECTORY ${VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname}}
            LOGNAME build-${_build_triplet}
        )
        
        if(VCPKG_TARGET_IS_OSX)
           # For some reason there will be an error on MacOSX without this clean!
            message(STATUS "Cleaning after build before install ${_build_triplet}")
            vcpkg_execute_required_process(
                COMMAND ${INVOKE_SINGLE} clean
                WORKING_DIRECTORY ${VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname}}
                LOGNAME cleaning-2-${_build_triplet}
            )
        endif()
        
        message(STATUS "Fixig makefile installation path ${_build_triplet}")
        qt_fix_makefile_install("${VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname}}")
        message(STATUS "Installing ${_build_triplet}")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE} install
            WORKING_DIRECTORY ${VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname}}
            LOGNAME package-${_build_triplet}
        )
        message(STATUS "Package ${_build_triplet} done")
        set(ENV{PATH} "${_path}")
        unset(_build_triplet)
    endforeach()
    

    
endfunction()
