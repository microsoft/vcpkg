## # vcpkg_build_cmake
##
## Build a cmake project.
##
## ## Usage:
## ```cmake
## vcpkg_build_cmake([DISABLE_PARALLEL] [TARGET <target>])
## ```
##
## ## Parameters:
## ### DISABLE_PARALLEL
## The underlying buildsystem will be instructed to not parallelize
##
## ### TARGET
## The target passed to the cmake build command (`cmake --build . --target <target>`). If not specified, no target will
## be passed.
##
## ### ADD_BIN_TO_PATH
## Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.
##
## ## Notes:
## This command should be preceeded by a call to [`vcpkg_configure_cmake()`](vcpkg_configure_cmake.md).
## You can use the alias [`vcpkg_install_cmake()`](vcpkg_configure_cmake.md) function if your CMake script supports the
## "install" target
##
## ## Examples:
##
## * [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
## * [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
## * [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
## * [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
function(vcpkg_build_cmake)
    cmake_parse_arguments(_bc "DISABLE_PARALLEL;ADD_BIN_TO_PATH" "TARGET;LOGFILE_ROOT" "" ${ARGN})

    if(NOT _bc_LOGFILE_ROOT)
        set(_bc_LOGFILE_ROOT "build")
    endif()

    set(PARALLEL_ARG)
    set(NO_PARALLEL_ARG)

    if(_VCPKG_CMAKE_GENERATOR MATCHES "Ninja")
        set(BUILD_ARGS "-v") # verbose output
        set(NO_PARALLEL_ARG "-j1")
    elseif(_VCPKG_CMAKE_GENERATOR MATCHES "Visual Studio")
        set(BUILD_ARGS
            "/p:VCPkgLocalAppDataDisabled=true"
            "/p:UseIntelMKL=No"
        )
        set(PARALLEL_ARG "/m")
    elseif(_VCPKG_CMAKE_GENERATOR MATCHES "NMake")
        # No options are currently added for nmake builds
    else()
        message(FATAL_ERROR "Unrecognized GENERATOR setting from vcpkg_configure_cmake(). Valid generators are: Ninja, Visual Studio, and NMake Makefiles")
    endif()

    if(_bc_TARGET)
        set(TARGET_PARAM "--target" ${_bc_TARGET})
    else()
        set(TARGET_PARAM)
    endif()

    if(_bc_DISABLE_PARALLEL)
        set(PARALLEL_ARG ${NO_PARALLEL_ARG})
    endif()

    foreach(BUILDTYPE "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
            if(BUILDTYPE STREQUAL "debug")
                set(SHORT_BUILDTYPE "dbg")
                set(CONFIG "Debug")
            else()
                set(SHORT_BUILDTYPE "rel")
                set(CONFIG "Release")
            endif()

            message(STATUS "Building ${TARGET_TRIPLET}-${SHORT_BUILDTYPE}")
            set(LOGPREFIX "${CURRENT_BUILDTREES_DIR}/${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}")
            set(LOGS)

            if(_bc_ADD_BIN_TO_PATH)
                set(_BACKUP_ENV_PATH "$ENV{PATH}")
                if(CMAKE_HOST_WIN32)
                    set(_PATHSEP ";")
                else()
                    set(_PATHSEP ":")
                endif()
                if(BUILDTYPE STREQUAL "debug")
                    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/bin${_PATHSEP}$ENV{PATH}")
                else()
                    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin${_PATHSEP}$ENV{PATH}")
                endif()
            endif()
            execute_process(
                COMMAND ${CMAKE_COMMAND} --build . --config ${CONFIG} ${TARGET_PARAM} -- ${BUILD_ARGS} ${PARALLEL_ARG}
                OUTPUT_FILE "${LOGPREFIX}-out.log"
                ERROR_FILE "${LOGPREFIX}-err.log"
                RESULT_VARIABLE error_code
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE})
            if(error_code)
                file(READ "${LOGPREFIX}-out.log" out_contents)
                file(READ "${LOGPREFIX}-err.log" err_contents)

                if(out_contents)
                    list(APPEND LOGS "${LOGPREFIX}-out.log")
                endif()
                if(err_contents)
                    list(APPEND LOGS "${LOGPREFIX}-err.log")
                endif()

                if(out_contents MATCHES "LINK : fatal error LNK1102:" OR out_contents MATCHES " fatal error C1060: ")
                    # The linker ran out of memory during execution. We will try continuing once more, with parallelism disabled.
                    message(STATUS "Restarting Build ${TARGET_TRIPLET}-${SHORT_BUILDTYPE} without parallelism because memory exceeded")
                    execute_process(
                        COMMAND ${CMAKE_COMMAND} --build . --config ${CONFIG} ${TARGET_PARAM} -- ${BUILD_ARGS} ${NO_PARALLEL_ARG}
                        OUTPUT_FILE "${LOGPREFIX}-out-1.log"
                        ERROR_FILE "${LOGPREFIX}-err-1.log"
                        RESULT_VARIABLE error_code
                        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE})

                    if(error_code)
                        file(READ "${LOGPREFIX}-out-1.log" out_contents)
                        file(READ "${LOGPREFIX}-err-1.log" err_contents)

                        if(out_contents)
                            list(APPEND LOGS "${LOGPREFIX}-out-1.log")
                        endif()
                        if(err_contents)
                            list(APPEND LOGS "${LOGPREFIX}-err-1.log")
                        endif()
                    endif()
                elseif(out_contents MATCHES ": No such file or directory")
                    # WSL workaround - WSL occassionally fails with no such file or directory. Detect if we are running in WSL and restart.
                    execute_process(COMMAND "uname" "-r"
                        OUTPUT_VARIABLE UNAME_R ERROR_VARIABLE UNAME_R
                        OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE)

                    if (UNAME_R MATCHES "Microsoft")
                        set(ITERATION 0)
                        while (ITERATION LESS 10 AND out_contents MATCHES ": No such file or directory")
                            MATH(EXPR ITERATION "${ITERATION}+1")
                            message(STATUS "Restarting Build ${TARGET_TRIPLET}-${SHORT_BUILDTYPE} because of wsl subsystem issue. Iteration: ${ITERATION}")
                            execute_process(
                                COMMAND ${CMAKE_COMMAND} --build . --config ${CONFIG} ${TARGET_PARAM} -- ${BUILD_ARGS}
                                OUTPUT_FILE "${LOGPREFIX}-out-${ITERATION}.log"
                                ERROR_FILE "${LOGPREFIX}-err-${ITERATION}.log"
                                RESULT_VARIABLE error_code
                                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE})

                            if(error_code)
                                file(READ "${LOGPREFIX}-out-${ITERATION}.log" out_contents)
                                file(READ "${LOGPREFIX}-err-${ITERATION}.log" err_contents)

                                if(out_contents)
                                    list(APPEND LOGS "${LOGPREFIX}-out-${ITERATION}.log")
                                endif()
                                if(err_contents)
                                    list(APPEND LOGS "${LOGPREFIX}-err-${ITERATION}.log")
                                endif()
                            else()
                                break()
                            endif()
                        endwhile()
                    endif()
                endif()

                if(error_code)
                    set(STRINGIFIED_LOGS)
                    foreach(LOG ${LOGS})
                        file(TO_NATIVE_PATH "${LOG}" NATIVE_LOG)
                        list(APPEND STRINGIFIED_LOGS "    ${NATIVE_LOG}\n")
                    endforeach()
                    set(_eb_COMMAND ${CMAKE_COMMAND} --build . --config ${CONFIG} ${TARGET_PARAM} -- ${BUILD_ARGS} ${NO_PARALLEL_ARG})
                    set(_eb_WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE})
                    message(FATAL_ERROR
                        "  Command failed: ${_eb_COMMAND}\n"
                        "  Working Directory: ${_eb_WORKING_DIRECTORY}\n"
                        "  See logs for more information:\n"
                        ${STRINGIFIED_LOGS})
                endif()
            endif()
            if(_bc_ADD_BIN_TO_PATH)
                set(ENV{PATH} "${_BACKUP_ENV_PATH}")
            endif()
        endif()
    endforeach()
endfunction()
