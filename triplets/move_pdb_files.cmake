set(Z_VCPKG_BUILD_PATH_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
set(Z_VCPKG_BUILD_PATH_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")


function(z_vcpkg_copy_pdbs)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "BUILD_PATH_RELEASE;BUILD_PATH_DEBUG" "")


    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    file(GLOB_RECURSE rel_dlls_or_exe "${CURRENT_PACKAGES_DIR}/*.dll" "${CURRENT_PACKAGES_DIR}/*.exe")
    set(dbg_dlls_or_exe "${rel_dlls_or_exe}")
    list(FILTER dbg_dlls_or_exe INCLUDE REGEX "(${CURRENT_PACKAGES_DIR}/([^/]+/)*debug/)")
    list(FILTER rel_dlls_or_exe EXCLUDE REGEX "(${CURRENT_PACKAGES_DIR}/([^/]+/)*debug/)")

    file(GLOB_RECURSE build_rel_pdbs "${Z_VCPKG_BUILD_PATH_RELEASE}/*.pdb")
    set(build_rel_vc_pdbs "${build_rel_pdbs}")
    list(FILTER build_rel_vc_pdbs INCLUDE REGEX "/[Vv][Cc][0-9]+\\\.pdb")
    list(FILTER build_rel_pdbs    EXCLUDE REGEX "/[Vv][Cc][0-9]+\\\.pdb")
    #list(FILTER build_rel_pdbs    INCLUDE REGEX "/\\\.libs/")   # libtool build folder
    file(GLOB_RECURSE build_dbg_pdbs "${Z_VCPKG_BUILD_PATH_DEBUG}/*.pdb")
    set(build_dbg_vc_pdbs "${build_rel_pdbs}")
    list(FILTER build_dbg_vc_pdbs INCLUDE REGEX "/[Vv][Cc][0-9]+\\\.pdb")
    list(FILTER build_dbg_pdbs    EXCLUDE REGEX "/[Vv][Cc][0-9]+\\\.pdb")
    #list(FILTER build_dbg_pdbs    INCLUDE REGEX "/\\\.libs/")   # libtool build folder
    
    message(STATUS "${Z_VCPKG_BUILD_PATH_RELEASE}/*.pdb")
    message(STATUS "build_rel_pdbs:${build_rel_pdbs}")
    message(STATUS "build_rel_vc_pdbs:${build_rel_vc_pdbs}")

    set(vslang_backup "$ENV{VSLANG}")
    set(ENV{VSLANG} 1033) # to get english output from dumpbin

    set(no_matching_pdbs "")
    #If you specify a path name that does not include a file name (the path ends in backslash), the compiler creates a .pdb file named VCx.pdb in the specified directory.

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/" current_packages_native)
    file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/" current_buildtrees_native)
    string(REPLACE [[\]] [[\\]] current_packages_native "${current_packages_native}")
    string(REPLACE [[\]] [[\\]] current_buildtrees_native "${current_buildtrees_native}")

    function(not_found dll_or_exe)
        list(APPEND no_matching_pdbs "${dll_or_exe}")
        set(no_matching_pdbs "${no_matching_pdbs}" PARENT_SCOPE)
    endfunction()

    function(ambigous_pdbs_found dll_or_exe found_pdbs)
        message(FATAL_ERROR "More than one possible pdb for '${dll_or_exe}' found: '${found_pdbs}'! Please install the correct pdb manually!")
    endfunction()

    function(install_found_pdb dll_or_exe found_pdb)
        cmake_path(GET dll_or_exe PARENT_PATH dll_or_exe_dir)
        file(INSTALL "${found_pdb}" DESTINATION "${dll_or_exe_dir}") 
    endfunction()

    function(find_path_pdb_in_buildtree dll_or_exe search_pdbs found_pdbs function_found function_ambigous function_not_found)
        list(LENGTH found_pdbs found_pdbs_length)
        if(found_pdbs_length EQUAL "1")
            cmake_language(CALL "${function_found}" "${dll_or_exe}" "${found_pdbs}")
        elseif(found_pdbs_length GREATER "1")
            cmake_language(CALL "${function_ambigous}" "${dll_or_exe}" "${search_pdbs}" "${found_pdbs}")
        else()
            cmake_language(CALL "${function_not_found}" "${dll_or_exe}" "${search_pdbs}" "${found_pdbs}")
        endif()
        set(no_matching_pdbs "${no_matching_pdbs}" PARENT_SCOPE)
    endfunction()

    macro(normalize_pdbs_path_and_regex pdb_match_var pdb_path_out pdb_regex_out)
        file(TO_CMAKE_PATH "${${pdb_match_var}}" "${pdb_path_out}")
        string(REPLACE "${CURRENT_PACKAGES_DIR}/${packages_subpath}" "" "${pdb_path_out}" "${${pdb_path_out}}")
        string(REPLACE [[.]] [[\.]] "${pdb_regex_out}" "${${pdb_path_out}}")
    endmacro()

    macro(normalize_pdbs_path_and_regex_filename_only pdb_match_var pdb_path_out pdb_regex_out)
        file(TO_CMAKE_PATH "${${pdb_match_var}}" "${pdb_path_out}")
        cmake_path(GET "${pdb_path_out}" FILENAME "${pdb_path_out}")
        string(REPLACE [[.]] [[\.]] "${pdb_regex_out}" "${${pdb_path_out}}")
    endmacro()


    function(find_ambigous_retry_1 dll_or_exe search_pdbs found_pdbs)
        list(FILTER found_pdbs INCLUDE REGEX "/\\\.libs/") # libtool build folder
        find_path_pdb_in_buildtree("${dll_or_exe}" "${search_pdbs}" "${found_pdbs}" install_found_pdb ambigous_pdbs_found not_found)
        set(no_matching_pdbs "${no_matching_pdbs}" PARENT_SCOPE)
    endfunction()

    function(find_pdb_by_name dll_or_exe search_pdbs)
        normalize_pdbs_path_and_regex_filename_only(CMAKE_MATCH_1 pdb_path pdb_regex) # only name lookup
        set(found_pdbs "${search_pdbs}")
        list(FILTER found_pdbs INCLUDE REGEX "${pdb_regex}")
        find_path_pdb_in_buildtree("${dll_or_exe}" "${search_pdbs}" "${found_pdbs}" install_found_pdb find_ambigous_retry_1 not_found)
        set(no_matching_pdbs "${no_matching_pdbs}" PARENT_SCOPE)
    endfunction()

    macro(analyze_dumpbin_pdbs dll_or_exe search_pdbs_var pdb_lines_var packages_subpath)
        if(pdb_lines MATCHES "PDB file found at '(${current_buildtrees_native}[^']+)'")
            message(WARNING "File: '${dll_or_exe}' encodes absolute path to a pdb in the buildtree!")
        endif()
        set(pdb_not_found TRUE)
        if(${pdb_lines_var} MATCHES "PDB file found at.*'([^']+)'") # Found case
            message(STATUS "CMAKE_MATCH_COUNT:${CMAKE_MATCH_COUNT}")
            file(TO_CMAKE_PATH "${CMAKE_MATCH_1}" pdb_found_path)
            if(NOT pdb_found_path MATCHES "${CURRENT_PACKAGES_DIR}")
                message(FATAL_ERROR "PDB found outside vcpkg package dir: ${pdb_found_path}") # pdb found outside vcpkg
            else()
                message(STATUS "PDB found: '${pdb_found_path}'") # pdb already installed
                set(pdb_not_found TRUE)
                continue()
            endif()
        endif()
        if(${pdb_lines_var} MATCHES "PDB file '([^']+)'") # Not found case. 
            normalize_pdbs_path_and_regex(CMAKE_MATCH_1 pdb_path pdb_regex) # MATCH_1 is same dir/name lookup, e.g. bin/somelib.pdb
            set(found_pdbs "${${search_pdbs_var}}")
            list(FILTER found_pdbs INCLUDE REGEX "${pdb_regex}")
            find_path_pdb_in_buildtree("${dll_or_exe}" "${${search_pdbs_var}}" "${found_pdbs}" install_found_pdb ambigous_pdbs_found find_pdb_by_name)
        elseif(pdb_not_found)
            list(APPEND no_matching_pdbs "${dll_or_exe}")
        endif()
    endmacro()

    find_program(DUMPBIN NAMES dumpbin)
    find_program(FINDSTR NAMES findstr)
    # Release pdbs
    foreach(dll_or_exe IN LISTS rel_dlls_or_exe)
        execute_process(COMMAND "${DUMPBIN}" /NOLOGO /PDBPATH:VERBOSE "${dll_or_exe}"
                        COMMAND "${FINDSTR}" PDB
            OUTPUT_VARIABLE pdb_lines
            ERROR_QUIET
            RESULT_VARIABLE error_code
        )
        ## Alternatives to dumpbin:
        ## llvm-readobj --coff-debug-directory bin/szip.dll
        ## PDBFileName: szip.pdb
        
        ## For Dlls deps:
        ## llvm-readobj --needed-libs bin/szip.dll
        # NeededLibraries [
        #   KERNEL32.dll
        #   VCRUNTIME140.dll
        #   api-ms-win-crt-heap-l1-1-0.dll
        #   api-ms-win-crt-runtime-l1-1-0.dll
        # ]
        
        if(NOT error_code EQUAL "0")
            message(FATAL_ERROR "Unable to run dumpbin! Error code: ${error_code}")
        endif()
        set(search_pdbs "${build_rel_pdbs}")
        analyze_dumpbin_pdbs("${dll_or_exe}" search_pdbs pdb_lines "")
        if(pdb_lines MATCHES "PDB file found at '(${current_buildtrees_native}[^']+)'")
            message(WARNING "File: '${dll_or_exe}' encodes absolute path to a pdb in the buildtree!")
        endif()
    endforeach()
    # Debug pdbs
    foreach(dll_or_exe IN LISTS dbg_dlls_or_exe)
        execute_process(COMMAND "${DUMPBIN}" /NOLOGO /PDBPATH:VERBOSE "${dll_or_exe}"
                        COMMAND "${FINDSTR}" PDB
            OUTPUT_VARIABLE pdb_lines
            ERROR_QUIET
            RESULT_VARIABLE error_code
        )
        if(NOT error_code EQUAL "0")
            message(FATAL_ERROR "Unable to run dumpbin! Error code: ${error_code}")
        endif()
        set(search_pdbs "${build_dbg_pdbs}")
        analyze_dumpbin_pdbs("${dll_or_exe}" search_pdbs pdb_lines "debug/")
    endforeach()

    set(ENV{VSLANG} "${vslang_backup}")

    if(NOT no_matching_pdbs STREQUAL "")
        list(JOIN no_matching_pdbs "\n\t" msg)
        message(WARNING "Could not find a matching pdb file for:\n${msg}\n")
    endif()
endfunction()

z_vcpkg_copy_pdbs()