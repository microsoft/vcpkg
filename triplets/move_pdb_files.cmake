function(z_vcpkg_copy_pdbs)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    file(GLOB_RECURSE rel_dlls_or_exe "${CURRENT_PACKAGES_DIR}/*.dll" "${CURRENT_PACKAGES_DIR}/*.exe")
    set(dbg_dlls_or_exe "${rel_dlls_or_exe}")
    list(FILTER dbg_dlls_or_exe INCLUDE "${CURRENT_PACKAGES_DIR}/debug/")
    list(FILTER rel_dlls_or_exe EXCLUDE "${CURRENT_PACKAGES_DIR}/debug/")

    set(vslang_backup "$ENV{VSLANG}")
    set(ENV{VSLANG} 1033)

    set(dlls_without_matching_pdbs "")

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
        list(JOIN dlls_without_matching_pdbs "\n\t" msg)
        message(WARNING "Could not find a matching pdb file for:\n${msg}\n")
    endif()
endfunction()

z_vcpkg_copy_pdbs()