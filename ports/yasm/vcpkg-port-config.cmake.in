set(Z_YASM_TOOL_HELPER_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(yasm_tool_helper)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "APPEND_TO_PATH;PREPEND_TO_PATH"
        "OUT_VAR"
        ""
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unexpected arguments to yasm_tool_helper: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    find_program(YASM yasm PATHS "${Z_YASM_TOOL_HELPER_LIST_DIR}/../../tools/yasm")

    if(arg_APPEND_TO_PATH)
        get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
        vcpkg_add_to_path("${YASM_EXE_PATH}")
    endif()
    if(arg_PREPEND_TO_PATH)
        get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
        vcpkg_add_to_path(PREPEND "${YASM_EXE_PATH}")
    endif()
    if(DEFINED arg_OUT_VAR)
        set("${arg_OUT_VAR}" "${YASM}" PARENT_SCOPE)
    endif()
endfunction()
