function(vcpkg_copy_pdbs)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "BUILD_PATHS")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_BUILD_PATHS)
        set(arg_BUILD_PATHS
            "${CURRENT_PACKAGES_DIR}/bin/*.dll"
            "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
        )
    endif()

    set(dlls_without_matching_pdbs "")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        file(GLOB_RECURSE dlls ${arg_BUILD_PATHS})

        set(vslang_backup "$ENV{VSLANG}")
        set(ENV{VSLANG} 1033)

        foreach(dll IN LISTS dlls)
            execute_process(COMMAND dumpbin /PDBPATH "${dll}"
                            COMMAND findstr PDB
                OUTPUT_VARIABLE pdb_line
                ERROR_QUIET
                RESULT_VARIABLE error_code
            )

            if(error_code EQUAL "0" AND pdb_line MATCHES "PDB file found at.*'(.*)'")
                set(pdb_path "${CMAKE_MATCH_1}")
                cmake_path(GET dll PARENT_PATH dll_dir)
                file(COPY "${pdb_path}" DESTINATION "${dll_dir}")
            else()
                list(APPEND dlls_without_matching_pdbs "${dll}")
            endif()
        endforeach()

        set(ENV{VSLANG} "${vslang_backup}")

        if(NOT dlls_without_matching_pdbs STREQUAL "")
            list(JOIN dlls_without_matching_pdbs "\n    " message)
            message(WARNING "Could not find a matching pdb file for:
    ${message}\n")
        endif()
    endif()

endfunction()
