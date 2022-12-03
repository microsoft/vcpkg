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
    set(debug_packages_prefix "${CURRENT_PACKAGES_DIR}/debug")

    set(dlls_without_matching_pdbs "")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
        file(GLOB_RECURSE dlls ${arg_BUILD_PATHS})
        
        set(USE_DUMPBIN TRUE)
        if(NOT VCPKG_HOST_IS_WINDOWS)
            set(USE_DUMPBIN FALSE)
        endif()

        if(USE_DUMPBIN)
            set(vslang_backup "$ENV{VSLANG}")
            set(ENV{VSLANG} 1033)
        endif()

        foreach(dll IN LISTS dlls)
            set(found_pdb FALSE)
            if(USE_DUMPBIN)
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
                    set(found_pdb TRUE)
                endif()
            endif()

            if(NOT found_pdb AND VCPKG_TARGET_IS_MINGW)
                # Support llvm / clang mingw (with PDB generation) in cross-compilation scenarios by looking for the default case
                # of a .pdb file matching the dll name in the build directory
                
                set(dll_build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
                cmake_path(IS_PREFIX debug_packages_prefix "${dll}" NORMALIZE is_debug_package)
                if(is_debug_package)
                    set(dll_build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
                endif()

                cmake_path(GET dll STEM LAST_ONLY dll_name)
                cmake_path(GET dll PARENT_PATH dll_dir)
                set(pdb_path "${dll_build_dir}/${dll_name}.pdb")
                if (EXISTS "${pdb_path}")
                    file(COPY "${pdb_path}" DESTINATION "${dll_dir}")
                    set(found_pdb TRUE)
                else()
                    file(GLOB_RECURSE pdb_path "${dll_build_dir}/${dll_name}.pdb")
                    list(LENGTH pdb_path pdb_path_count)
                    if(pdb_path_count EQUAL "1")
                        file(COPY "${pdb_path}" DESTINATION "${dll_dir}")
                        set(found_pdb TRUE)
                    else()
                        message(WARNING "Unexpectedly found more than one matching PDB for: ${dll}\n${pdb_path}\n")
                    endif()
                endif()
            endif()

            if(NOT found_pdb)
                list(APPEND dlls_without_matching_pdbs "${dll}")
            endif()
        endforeach()
        
        if(USE_DUMPBIN)
            set(ENV{VSLANG} "${vslang_backup}")
        endif()

        if(NOT dlls_without_matching_pdbs STREQUAL "")
            list(JOIN dlls_without_matching_pdbs "\n    " message)
            set(_message_level WARNING)
            if(VCPKG_TARGET_IS_MINGW)
                 set(_message_level STATUS) # not all mingw toolchains support generating .pdb
            endif()
            message(${_message_level} "Could not find a matching pdb file for:
    ${message}\n")
        endif()
    endif()

endfunction()
