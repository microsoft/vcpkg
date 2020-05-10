#.rst:
# .. command:: vcpkg_build_qmake
#
#  Build a qmake-based project, previously configured using vcpkg_configure_qmake.
#
#  ::
#  vcpkg_build_qmake()
#
function(vcpkg_build_qmake)
    cmake_parse_arguments(_csc "SKIP_MAKEFILES" "BUILD_LOGNAME" "TARGETS;RELEASE_TARGETS;DEBUG_TARGETS" ${ARGN})

    if(CMAKE_HOST_WIN32)
        vcpkg_find_acquire_program(JOM)
        set(INVOKE "${JOM}")
    else()
        find_program(MAKE make)
        set(INVOKE "${MAKE}")
    endif()

    # Make sure that the linker finds the libraries used
    set(ENV_PATH_BACKUP "$ENV{PATH}")

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)

    if(NOT _csc_BUILD_LOGNAME)
        set(_csc_BUILD_LOGNAME build)
    endif()

    function(run_jom TARGETS LOG_PREFIX LOG_SUFFIX)
        message(STATUS "Package ${LOG_PREFIX}-${TARGET_TRIPLET}-${LOG_SUFFIX}")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE} -j ${VCPKG_CONCURRENCY} ${TARGETS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${LOG_SUFFIX}
            LOGNAME package-${LOG_PREFIX}-${TARGET_TRIPLET}-${LOG_SUFFIX}
        )
    endfunction()

    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(ENV_CL_BACKUP "$ENV{_CL_}")
    set(ENV{_CL_} "/utf-8")

    #Replace with VCPKG variables if PR #7733 is merged
    unset(BUILDTYPES)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(_buildname "DEBUG")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "dbg")
        set(_path_suffix_${_buildname} "/debug")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_buildname "RELEASE")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "rel")
        set(_path_suffix_${_buildname} "")
    endif()
    unset(_buildname)

    foreach(_buildname ${BUILDTYPES})
        set(_BUILD_PREFIX "${_path_suffix_${_buildname}}")
        vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}${_BUILD_PREFIX}/bin")
        vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}${_BUILD_PREFIX}/lib")
        list(APPEND _csc_${_buildname}_TARGETS ${_csc_TARGETS})
        if(NOT _csc_SKIP_MAKEFILES)
            run_jom(qmake_all makefiles ${_short_name_${_buildname}})
        endif()
        run_jom("${_csc_${_buildname}_TARGETS}" ${_csc_BUILD_LOGNAME} ${_short_name_${_buildname}})
        unset(_BUILD_PREFIX)
    endforeach()

    # Restore the original value of ENV{PATH}
    set(ENV{PATH} "${ENV_PATH_BACKUP}")
    set(ENV{_CL_} "${ENV_CL_BACKUP}")
endfunction()
