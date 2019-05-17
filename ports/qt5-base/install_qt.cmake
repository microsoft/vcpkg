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
    vcpkg_find_acquire_program(FLEX)
    get_filename_component(FLEX_EXE_PATH ${FLEX} DIRECTORY)
    #    vcpkg_find_acquire_program(BISON)
    #get_filename_component(BISON_EXE_PATH ${BISON} DIRECTORY)

    file(COPY ${FLEX} DESTINATION "${FLEX_EXE_PATH}/bin" )
    file(COPY "${FLEX_EXE_PATH}/win_bison.exe" DESTINATION "${FLEX_EXE_PATH}/bin" )
    file(RENAME "${FLEX_EXE_PATH}/bin/win_bison.exe" "${FLEX_EXE_PATH}/bin/bison.exe")
    file(RENAME "${FLEX_EXE_PATH}/bin/win_flex.exe" "${FLEX_EXE_PATH}/bin/flex.exe")
    file(COPY "${FLEX_EXE_PATH}/bin/flex.exe" DESTINATION "${FLEX_EXE_PATH}" )
    file(COPY "${FLEX_EXE_PATH}/bin/bison.exe" DESTINATION "${FLEX_EXE_PATH}" )
    vcpkg_add_to_path("${FLEX_EXE_PATH}")

    vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")


    message(STATUS "PATH: $ENV{PATH}")


    set(_path "$ENV{PATH}")

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Package ${TARGET_TRIPLET}-dbg")
        vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )
        vcpkg_execute_required_process(
            COMMAND ${INVOKE} install
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME package-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Package ${TARGET_TRIPLET}-dbg done")
    endif()
    
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Package ${TARGET_TRIPLET}-rel")
        set(ENV{PATH} "${_path}")
        vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME build-${TARGET_TRIPLET}-rel
        )
        vcpkg_execute_required_process(
            COMMAND ${INVOKE} install
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME package-${TARGET_TRIPLET}-rel
        )
        message(STATUS "Package ${TARGET_TRIPLET}-rel done")
    endif()
    
    set(ENV{PATH} "${_path}")
    
endfunction()
