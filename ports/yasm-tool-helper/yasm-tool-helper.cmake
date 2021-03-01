get_filename_component(_YASM_TOOL_INSTALL_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(_YASM_TOOL_INSTALL_DIR "${_YASM_TOOL_INSTALL_DIR}" DIRECTORY)

function(yasm_tool_helper)
    cmake_parse_arguments(PARSE_ARGV 0 a
        "APPEND_TO_PATH;PREPEND_TO_PATH"
        "OUT_VAR"
        ""
    )

    if(@VCPKG_TARGET_IS_WINDOWS@)
        set(YASM "${_YASM_TOOL_INSTALL_DIR}/tools/yasm-tool/yasm${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        if(NOT EXISTS "${YASM}")
            message(FATAL_ERROR "Cross-targetting ports requiring yasm require the host yasm-tool to be available. (${YASM}).")
        endif()
    else()
        vcpkg_find_acquire_program(YASM)
    endif()

    if(a_APPEND_TO_PATH)
        get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
        vcpkg_add_to_path("${YASM_EXE_PATH}")
    endif()
    if(a_PREPEND_TO_PATH)
        get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
        vcpkg_add_to_path(PREPEND "${YASM_EXE_PATH}")
    endif()
    if(a_OUT_VAR)
        set(${a_OUT_VAR} "${YASM}" PARENT_SCOPE)
    endif()
endfunction()
