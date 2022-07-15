set(Z_VCPKG_BUILD_PATH_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
set(Z_VCPKG_BUILD_PATH_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")


function(z_vcpkg_copy_pdbs)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "BUILD_PATH_RELEASE;BUILD_PATH_DEBUG" "")


    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    file(GLOB_RECURSE rel_dlls_or_exe "${CURRENT_PACKAGES_DIR}/*.dll" "${CURRENT_PACKAGES_DIR}/*.exe")
    set(dbg_dlls_or_exe "${rel_dlls_or_exe}")
    list(FILTER dbg_dlls_or_exe INCLUDE REGEX "${CURRENT_PACKAGES_DIR}/debug/")
    list(FILTER rel_dlls_or_exe EXCLUDE REGEX "${CURRENT_PACKAGES_DIR}/debug/")

    file(GLOB_RECURSE build_rel_pdbs "${Z_VCPKG_BUILD_PATH_RELEASE}/*.pdb")
    file(GLOB_RECURSE build_dbg_pdbs "${Z_VCPKG_BUILD_PATH_DEBUG}/*.pdb")

    message(STATUS "${Z_VCPKG_BUILD_PATH_RELEASE}/*.pdb")
    message(STATUS "build_rel_pdbs:${build_rel_pdbs}")
    
    set(vslang_backup "$ENV{VSLANG}")
    set(ENV{VSLANG} 1033)

    set(no_matching_pdbs "")

    #If you specify a path name that does not include a file name (the path ends in backslash), the compiler creates a .pdb file named VCx0.pdb in the specified directory.

    foreach(dll_or_exe IN LISTS rel_dlls_or_exe)
        execute_process(COMMAND dumpbin /PDBPATH:VERBOSE "${dll_or_exe}"
                        COMMAND findstr PDB
            OUTPUT_VARIABLE pdb_lines
            ERROR_QUIET
            RESULT_VARIABLE error_code
        )
        if(NOT error_code EQUAL "0")
            message(FATAL_ERROR "Unable to run dumpbin! Error code: ${error_code}")
        endif()

        message(STATUS "pdb_lines:${pdb_lines}")
        file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/" current_packages_native)
        file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/" current_buildtrees_native)
        string(REPLACE [[\]] [[\\]] current_packages_native "${current_packages_native}")

        set(search_pdbs "${build_rel_pdbs}")

        if(pdb_line MATCHES "PDB file found at.*'([^']+)'")
            # pdb already installed
            message(STATUS "PDB found: ${CMAKE_MATCH_1}")
            continue() 
        elseif(pdb_lines MATCHES "PDB file '(${current_packages_native}[^']+)'")
            cmake_path(GET dll_or_exe PARENT_PATH dll_or_exe_dir)
            set(pdb_path "${CMAKE_MATCH_1}") # Match 1 is looking in the same directory. dllname -> pdbname 
            file(TO_CMAKE_PATH "${pdb_path}" pdb_path)
            string(REPLACE "${CURRENT_PACKAGES_DIR}/" "" pdb_path "${pdb_path}")
             message(STATUS "pdb_path:${pdb_path}")
            string(REPLACE [[.]] [[\.]] pdb_regex "${pdb_path}")
            set(found_pdbs "${search_pdbs}")
            list(FILTER found_pdbs INCLUDE REGEX "${pdb_regex}")
            message(STATUS "found_pdbs:${found_pdbs}") # Hopyfully only one
            list(LENGTH found_pdbs found_pdbs_length)
            if(found_pdbs_length EQUAL "1")
                file(COPY "${found_pdbs}" DESTINATION "${dll_or_exe_dir}") # All ok
            elseif(found_pdbs_length GREATER "1")
                message(FATAL_ERROR "More than one possible pdb for '${dll_or_exe}' found: '${found_pdbs}'! Please install the correct pdb manually!")
            elseif(found_pdbs_length EQUAL "0")
                #Couldn't find it retry with filename only 
                cmake_path(GET pdb_path FILENAME pdb_filename)
                string(REPLACE [[.]] [[\.]] pdb_regex "${pdb_filename}")
                set(found_pdbs "${search_pdbs}")
                list(FILTER found_pdbs INCLUDE REGEX "${pdb_regex}")
                list(LENGTH found_pdbs found_pdbs_length)
                if(found_pdbs_length EQUAL "1")
                    file(COPY "${found_pdbs_length}" DESTINATION "${dll_or_exe_dir}") # All ok
                elseif(found_pdbs_length GREATER "1")
                    message(FATAL_ERROR "More than one possible pdb for '${dll_or_exe}' found: '${found_pdbs}'! Please install the correct pdb manually!")
                elseif(found_pdbs_length EQUAL "0" AND DEFINED CMAKE_MATCH_2)
                    set(pdb_path "${CMAKE_MATCH_2}") # try match 2 -> /PDBALTNAME
                    cmake_path(GET pdb_path FILENAME pdb_filename)
                    string(REPLACE [[.]] [[\.]] pdb_regex "${pdb_filename}")
                    set(found_pdbs "${search_pdbs}")
                    list(FILTER found_pdbs INCLUDE REGEX "${pdb_regex}")
                    list(LENGTH found_pdbs found_pdbs_length)
                    if(found_pdbs_length EQUAL "1")
                        file(COPY "${found_pdbs}" DESTINATION "${dll_or_exe_dir}") # All ok
                    elseif(found_pdbs_length GREATER "1")
                        message(FATAL_ERROR "More than one possible pdb for '${dll_or_exe}' found: '${found_pdbs}'! Please install the correct pdb manually!")
                    elseif(found_pdbs_length EQUAL "0")
                        list(APPEND no_matching_pdbs "${dll_or_exe}")
                    endif()
                else()
                    list(APPEND no_matching_pdbs "${dll_or_exe}")
                endif()
            endif()
        else()
            list(APPEND no_matching_pdbs "${dll_or_exe}")
        endif()

        set(search_pdbs "${build_dbg_pdbs}")
        file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug/" current_packages_native)
        string(REPLACE [[\]] [[\\]] current_packages_native "${current_packages_native}")

        if(pdb_line MATCHES "PDB file found at.*'([^']+)'")
            # pdb already installed
            message(STATUS "PDB found: ${CMAKE_MATCH_1}")
            continue() 
        elseif(pdb_lines MATCHES "PDB file '(${current_packages_native}[^']+)'")
            cmake_path(GET dll_or_exe PARENT_PATH dll_or_exe_dir)
            set(pdb_path "${CMAKE_MATCH_1}") # Match 1 is looking in the same directory. dllname -> pdbname 
            file(TO_CMAKE_PATH "${pdb_path}" pdb_path)
            string(REPLACE "${CURRENT_PACKAGES_DIR}/debug" "" pdb_path "${pdb_path}")
             message(STATUS "pdb_path:${pdb_path}")
            string(REPLACE [[.]] [[\.]] pdb_regex "${pdb_path}")
            set(found_pdbs "${search_pdbs}")
            list(FILTER found_pdbs INCLUDE REGEX "${pdb_regex}")
            message(STATUS "found_pdbs:${found_pdbs}") # Hopyfully only one
            list(LENGTH found_pdbs found_pdbs_length)
            if(found_pdbs_length EQUAL "1")
                file(COPY "${found_pdbs}" DESTINATION "${dll_or_exe_dir}") # All ok
            elseif(found_pdbs_length GREATER "1")
                message(FATAL_ERROR "More than one possible pdb for '${dll_or_exe}' found: '${found_pdbs}'! Please install the correct pdb manually!")
            elseif(found_pdbs_length EQUAL "0")
                #Couldn't find it retry with filename only 
                cmake_path(GET pdb_path FILENAME pdb_filename)
                string(REPLACE [[.]] [[\.]] pdb_regex "${pdb_filename}")
                set(found_pdbs "${search_pdbs}")
                list(FILTER found_pdbs INCLUDE REGEX "${pdb_regex}")
                list(LENGTH found_pdbs found_pdbs_length)
                if(found_pdbs_length EQUAL "1")
                    file(COPY "${found_pdbs_length}" DESTINATION "${dll_or_exe_dir}") # All ok
                elseif(found_pdbs_length GREATER "1")
                    message(FATAL_ERROR "More than one possible pdb for '${dll_or_exe}' found: '${found_pdbs}'! Please install the correct pdb manually!")
                elseif(found_pdbs_length EQUAL "0" AND DEFINED CMAKE_MATCH_2)
                    set(pdb_path "${CMAKE_MATCH_2}") # try match 2 -> /PDBALTNAME
                    cmake_path(GET pdb_path FILENAME pdb_filename)
                    string(REPLACE [[.]] [[\.]] pdb_regex "${pdb_filename}")
                    set(found_pdbs "${search_pdbs}")
                    list(FILTER found_pdbs INCLUDE REGEX "${pdb_regex}")
                    list(LENGTH found_pdbs found_pdbs_length)
                    if(found_pdbs_length EQUAL "1")
                        file(COPY "${found_pdbs}" DESTINATION "${dll_or_exe_dir}") # All ok
                    elseif(found_pdbs_length GREATER "1")
                        message(FATAL_ERROR "More than one possible pdb for '${dll_or_exe}' found: '${found_pdbs}'! Please install the correct pdb manually!")
                    elseif(found_pdbs_length EQUAL "0")
                        list(APPEND no_matching_pdbs "${dll_or_exe}")
                    endif()
                else()
                    list(APPEND no_matching_pdbs "${dll_or_exe}")
                endif()
            endif()
        else()
            list(APPEND no_matching_pdbs "${dll_or_exe}")
        endif()


        # This needs to be outside the above if. 
        if(pdb_line MATCHES "PDB file found at.*'${current_buildtrees_native}(.*)'")
            message(WARNING "File: '${dll_or_exe}' encodes absolute path to a pdb in the buildtree!")
        endif()
    endforeach()

    set(ENV{VSLANG} "${vslang_backup}")

    if(NOT no_matching_pdbs STREQUAL "")
        list(JOIN no_matching_pdbs "\n\t" msg)
        message(WARNING "Could not find a matching pdb file for:\n${msg}\n")
    endif()
endfunction()

z_vcpkg_copy_pdbs()