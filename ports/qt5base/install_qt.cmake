function(install_qt)
    cmake_parse_arguments(_bc "DISABLE_PARALLEL" "" "" ${ARGN})

    if (_bc_DISABLE_PARALLEL)
        set(JOBS "1")
    else()
        set(JOBS "$ENV{NUMBER_OF_PROCESSORS}")
    endif()

    vcpkg_find_acquire_program(JOM)
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

    set(ENV{PATH} "${PYTHON3_EXE_PATH};$ENV{PATH}")
    set(_path "$ENV{PATH}")

    message(STATUS "Package ${TARGET_TRIPLET}-rel")
    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/bin;${_path}")
    vcpkg_execute_required_process(
        COMMAND ${JOM} /J ${JOBS}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
    vcpkg_execute_required_process(
        COMMAND ${JOM} /J ${JOBS} install
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME package-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Package ${TARGET_TRIPLET}-rel done")

    message(STATUS "Package ${TARGET_TRIPLET}-dbg")
    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/debug/bin;${_path}")
    vcpkg_execute_required_process(
        COMMAND ${JOM} /J ${JOBS}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )
    vcpkg_execute_required_process(
        COMMAND ${JOM} /J ${JOBS} install
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME package-${TARGET_TRIPLET}-dbg
    )
    set(ENV{PATH} "${_path}")
    message(STATUS "Package ${TARGET_TRIPLET}-dbg done")
endfunction()