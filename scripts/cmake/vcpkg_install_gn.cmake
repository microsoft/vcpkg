## # vcpkg_install_gn
##
## Installs a GN project
##
## ## Usage:
## ```cmake
## vcpkg_install_gn(
##      SOURCE_PATH <SOURCE_PATH>
##      [TARGETS <target>...]
## )
## ```
##
## ## Parameters:
## ### SOURCE_PATH
## The path to the source directory
## 
## ### TARGETS
## Only install the specified targets.
##
## Note: includes must be handled separately

function(vcpkg_install_gn)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _vig "" "SOURCE_PATH" "TARGETS")
    
    if(NOT DEFINED _vig_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified.")
    endif()

    vcpkg_build_ninja(TARGETS ${_vig_TARGETS})

    vcpkg_find_acquire_program(GN)

    function(gn_get_target_type OUT_VAR BUILD_DIR TARGET)
        execute_process(
            COMMAND ${GN} desc "${BUILD_DIR}" "${TARGET}"
            WORKING_DIRECTORY "${_vig_SOURCE_PATH}"
            OUTPUT_VARIABLE OUTPUT_
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        string(REGEX MATCH "type: ([A-Za-z0-9_]+)" OUTPUT_ "${OUTPUT_}")
        set(${OUT_VAR} ${CMAKE_MATCH_1} PARENT_SCOPE)
    endfunction()

    function(gn_desc OUT_VAR BUILD_DIR TARGET WHAT_TO_DISPLAY)
        execute_process(
            COMMAND ${GN} desc "${BUILD_DIR}" "${TARGET}" "${WHAT_TO_DISPLAY}"
            WORKING_DIRECTORY "${_vig_SOURCE_PATH}"
            OUTPUT_VARIABLE OUTPUT_
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        string(REGEX REPLACE "\n|(\r\n)" ";" OUTPUT_ "${OUTPUT_}")
        set(${OUT_VAR} ${OUTPUT_} PARENT_SCOPE)
    endfunction()

    function(install_ BUILD_DIR INSTALL_DIR)
        if(_vig_TARGETS)
            foreach(TARGET ${_vig_TARGETS})
                # GN targets must start with a //
                gn_desc(OUTPUTS "${BUILD_DIR}" "//${TARGET}" outputs)
                gn_get_target_type(TARGET_TYPE "${BUILD_DIR}" "//${TARGET}")
                foreach(OUTPUT ${OUTPUTS})
                    if(NOT EXISTS "${OUTPUT}")
                        if(OUTPUT MATCHES "^//")
                            # relative path (e.g. //out/Release/target.lib)
                            string(REGEX REPLACE "^//" "${_vig_SOURCE_PATH}/" OUTPUT "${OUTPUT}")
                        elseif(OUTPUT MATCHES "^/" AND CMAKE_HOST_WIN32)
                            # absolute path (e.g. /C:/path/to/target.lib)
                            string(REGEX REPLACE "^/" "" OUTPUT "${OUTPUT}")
                        endif()
                    endif()

                    if(NOT EXISTS "${OUTPUT}")
                        message(STATUS "Output for target, ${TARGET} doesn't exist: ${OUTPUT}.")
                        continue()
                    endif()
                    
                    if(TARGET_TYPE STREQUAL "executable")
                        file(INSTALL "${OUTPUT}" DESTINATION "${INSTALL_DIR}/tools")
                    elseif("${OUTPUT}" MATCHES "(\\.dll|\\.pdb)$")
                        file(INSTALL "${OUTPUT}" DESTINATION "${INSTALL_DIR}/bin")
                    else()
                        file(INSTALL "${OUTPUT}" DESTINATION "${INSTALL_DIR}/lib")
                    endif()
                endforeach()
            endforeach()
        endif()
    endfunction()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        install_("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" "${CURRENT_PACKAGES_DIR}/debug")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        install_("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "${CURRENT_PACKAGES_DIR}")
    endif()

endfunction()