function(yasm_tool_helper)
    cmake_parse_arguments(PARSE_ARGV 0 a
        "APPEND_TO_PATH;PREPEND_TO_PATH"
        "OUT_VAR"
        ""
    )

    if(CMAKE_HOST_WIN32)
        if(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP)
            # Native compilation
            set(YASM "${CURRENT_INSTALLED_DIR}/tools/yasm-tool/yasm.exe")
        else()
            # Cross compilation
            get_filename_component(YASM "${CURRENT_INSTALLED_DIR}/../x86-windows/tools/yasm-tool/yasm.exe" ABSOLUTE)
            if(NOT EXISTS "${YASM}")
                message(FATAL_ERROR "Cross-targetting and x64 ports requiring yasm require the x86-windows yasm-tool to be available. Please install yasm-tool:x86-windows first.")
            endif()
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
