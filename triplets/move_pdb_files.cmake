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

    file(GLOB_RECURSE rel_dlls_installed "${CURRENT_INSTALLED_DIR}/*.dll")
    set(dbg_dlls_installed "${rel_dlls_installed}")
    list(FILTER dbg_dlls_installed INCLUDE REGEX "(${CURRENT_INSTALLED_DIR}/([^/]+/)*debug/)")
    list(FILTER rel_dlls_installed EXCLUDE REGEX "(${CURRENT_INSTALLED_DIR}/([^/]+/)*debug/)")

    string(REGEX REPLACE "${CURRENT_INSTALLED_DIR}/([^/;]+/)*" "" rel_dlls_installed "${rel_dlls_installed}")
    string(REGEX REPLACE "${CURRENT_INSTALLED_DIR}/([^/;]+/)*" "" dbg_dlls_installed "${dbg_dlls_installed}")
    #string(REPLACE "." "\\\." rel_dlls_installed "${rel_dlls_installed}")
    #string(REPLACE "." "\\\." dbg_dlls_installed "${dbg_dlls_installed}")
    #string(REPLACE "+" "\\\+" rel_dlls_installed "${rel_dlls_installed}")
    #string(REPLACE "+" "\\\+" dbg_dlls_installed "${dbg_dlls_installed}")
    #string(REPLACE "*" "\\\*" rel_dlls_installed "${rel_dlls_installed}")
    #string(REPLACE "*" "\\\*" dbg_dlls_installed "${dbg_dlls_installed}")
    #list(JOIN rel_dlls_installed "|" rel_dlls_installed)
    #list(JOIN dbg_dlls_installed "|" dbg_dlls_installed)
    #list(FILTER rel_dlls_or_exe EXCLUDE REGEX "/(${rel_dlls_installed})") # This Regex will be too long for cmake to handle
    #list(FILTER dbg_dlls_or_exe EXCLUDE REGEX "/(${dbg_dlls_installed})")

    file(GLOB_RECURSE build_rel_pdbs "${Z_VCPKG_BUILD_PATH_RELEASE}/*.pdb")
    set(build_rel_vc_pdbs "${build_rel_pdbs}")
    list(FILTER build_rel_vc_pdbs INCLUDE REGEX "/[Vv][Cc][0-9]+\\\.pdb")
    list(FILTER build_rel_pdbs    EXCLUDE REGEX "/[Vv][Cc][0-9]+\\\.pdb")

    file(GLOB_RECURSE build_dbg_pdbs "${Z_VCPKG_BUILD_PATH_DEBUG}/*.pdb")
    set(build_dbg_vc_pdbs "${build_rel_pdbs}")
    list(FILTER build_dbg_vc_pdbs INCLUDE REGEX "/[Vv][Cc][0-9]+\\\.pdb")
    list(FILTER build_dbg_pdbs    EXCLUDE REGEX "/[Vv][Cc][0-9]+\\\.pdb")

    set(vslang_backup "$ENV{VSLANG}")
    set(ENV{VSLANG} 1033) # to get english output from dumpbin

    set(no_matching_pdbs "")
    #If you specify a path name that does not include a file name (the path ends in backslash), the compiler creates a .pdb file named VCx.pdb in the specified directory.

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/" current_packages_native)
    file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/" current_buildtrees_native)
    string(REPLACE [[\]] [[\\]] current_packages_native "${current_packages_native}")
    string(REPLACE [[\]] [[\\]] current_buildtrees_native "${current_buildtrees_native}")

    function(not_found dll_or_exe)
        string(STRIP "${dll_or_exe}" stripped)
        list(APPEND no_matching_pdbs "${stripped}")
        set(no_matching_pdbs "${no_matching_pdbs}" PARENT_SCOPE)
    endfunction()

    function(ambigous_pdbs_found dll_or_exe found_pdbs)
        message(FATAL_ERROR "More than one possible pdb for '${dll_or_exe}' found: '${found_pdbs}'! Please install the correct pdb manually!")
    endfunction()

    function(install_found_pdb dll_or_exe found_pdb)
        cmake_path(GET dll_or_exe PARENT_PATH dll_or_exe_dir)
        file(INSTALL "${found_pdb}" DESTINATION "${dll_or_exe_dir}")
        set(pdb_not_found FALSE PARENT_SCOPE)
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
        set(pdb_not_found "${pdb_not_found}" PARENT_SCOPE)
    endfunction()

    function(find_ambigous_retry_1 dll_or_exe search_pdbs found_pdbs)
        list(FILTER found_pdbs INCLUDE REGEX "/\\\.libs/") # libtool build folder
        find_path_pdb_in_buildtree("${dll_or_exe}" "${search_pdbs}" "${found_pdbs}" install_found_pdb ambigous_pdbs_found not_found)
        set(no_matching_pdbs "${no_matching_pdbs}" PARENT_SCOPE)
        set(pdb_not_found "${pdb_not_found}" PARENT_SCOPE)
    endfunction()

    function(find_pdb_by_name dll_or_exe search_pdbs)
        cmake_path(GET pdb_path_not_found FILENAME pdb_path)
        if(pdb_path MATCHES "[Vv][Cc][0-9]?[0-9][0-9]\\\.pdb")
            message(FATAL_ERROR "Error cannot install pdb with generic name '${CMAKE_MATCH_O}' found in ${dll_or_exe}")
        endif()
        string(REPLACE [[.]] [[\.]] pdb_regex "${pdb_path}")
        string(REPLACE [[+]] [[\+]] pdb_regex "${pdb_regex}")
        string(REPLACE [[*]] [[\*]] pdb_regex "${pdb_regex}")
        set(found_pdbs "${search_pdbs}")
        list(FILTER found_pdbs INCLUDE REGEX "/${pdb_regex}")
        find_path_pdb_in_buildtree("${dll_or_exe}" "${search_pdbs}" "${found_pdbs}" install_found_pdb find_ambigous_retry_1 not_found)
        set(no_matching_pdbs "${no_matching_pdbs}" PARENT_SCOPE)
        set(pdb_not_found "${pdb_not_found}" PARENT_SCOPE)
    endfunction()

    macro(analyze_dumpbin_pdbs dll_or_exe search_pdbs_var pdb_lines_var packages_subpath)
        string(REGEX MATCHALL  "PDB file '([^']+)'" pdb_paths_not_found "${${pdb_lines_var}}")  # This will always have 4 elements
        list(TRANSFORM pdb_paths_not_found REPLACE "PDB file '([^']+)'" "\\1")
        cmake_path(CONVERT "${pdb_paths_not_found}" TO_CMAKE_PATH_LIST pdb_paths_not_found)
        message(DEBUG "pdb_paths_not_found: ${pdb_paths_not_found}")
        string(REGEX MATCHALL  "PDB file found at '([^']+)'" pdb_path_found "${${pdb_lines_var}}") # This will always be just 1 element
        list(TRANSFORM pdb_path_found REPLACE "PDB file found at '([^']+)'" "\\1")
        cmake_path(CONVERT "${pdb_path_found}" TO_CMAKE_PATH_LIST pdb_path_found)
        message(DEBUG "pdb_path_found: ${pdb_path_found}")
        
        set(pdb_not_found TRUE)
        if(pdb_path_found AND pdb_path_found MATCHES "${CURRENT_BUILDTREES_DIR}") # This is the old vcpkg behavior
            message(WARNING "File: '${dll_or_exe}' encodes absolute path to a pdb to the buildtree!")
            install_found_pdb("${dll_or_exe}" "${pdb_path_found}")
        elseif(pdb_path_found AND NOT pdb_path_found MATCHES "${CURRENT_PACKAGES_DIR}")
            message(FATAL_ERROR "PDB found outside vcpkg package dir: ${pdb_path_found}") # pdb found outside vcpkg
        elseif(pdb_path_found AND pdb_path_found MATCHES "${CURRENT_PACKAGES_DIR}")
            message(VERBOSE "PDB for '${dll_or_exe}' already installed at: ${pdb_path_found}")
            set(pdb_not_found FALSE)
        endif()

        foreach(pdb_path_not_found IN LISTS pdb_paths_not_found)
            if(NOT pdb_not_found)
                break()
            endif()
            set(found_pdbs "${${search_pdbs_var}}")
            string(REPLACE "${CURRENT_PACKAGES_DIR}/${packages_subpath}" "" pdb_path "${pdb_path_not_found}")
            string(REPLACE [[.]] [[\.]] pdb_regex "${pdb_path}")
            string(REPLACE [[+]] [[\+]] pdb_regex "${pdb_regex}")
            string(REPLACE [[*]] [[\*]] pdb_regex "${pdb_regex}")
            list(FILTER found_pdbs INCLUDE REGEX "/${pdb_regex}")
            find_path_pdb_in_buildtree("${dll_or_exe}" "${${search_pdbs_var}}" "${found_pdbs}" install_found_pdb ambigous_pdbs_found find_pdb_by_name)
        endforeach()
    endmacro()

    find_program(DUMPBIN NAMES dumpbin)
    find_program(FINDSTR NAMES findstr)

    # Release pdbs
    foreach(dll_or_exe IN LISTS rel_dlls_or_exe)
        cmake_path(GET dll_or_exe FILENAME dll_or_exe_filename)
        list(FIND rel_dlls_installed "${dll_or_exe_filename}" already_installed)
        if(NOT already_installed EQUAL "-1")
            continue()
        endif()

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
        
        if(NOT error_code EQUAL "0" AND pdb_lines) # If findstr doesn't match anything it will also return -1; So test for output via pdb_lines
            message(FATAL_ERROR "Unable to run dumpbin and findstr! Error code: ${error_code};${pdb_lines}")
        endif()
        if(pdb_lines)
            set(search_pdbs "${build_rel_pdbs}")
            analyze_dumpbin_pdbs("${dll_or_exe}" search_pdbs pdb_lines "")
            if(pdb_not_found)
                list(APPEND no_matching_pdbs "${dll_or_exe}")
            endif()
        endif()
    endforeach()
    # Debug pdbs
    foreach(dll_or_exe IN LISTS dbg_dlls_or_exe)
        cmake_path(GET dll_or_exe FILENAME dll_or_exe_filename)
        list(FIND dbg_dlls_installed "${dll_or_exe_filename}" already_installed)
        if(NOT already_installed EQUAL "-1")
            continue()
        endif()
        execute_process(COMMAND "${DUMPBIN}" /NOLOGO /PDBPATH:VERBOSE "${dll_or_exe}"
                        COMMAND "${FINDSTR}" PDB
            OUTPUT_VARIABLE pdb_lines
            ERROR_QUIET
            RESULT_VARIABLE error_code
        )
        if(NOT error_code EQUAL "0" AND pdb_lines) # If findstr doesn't match anything it will also return -1; So test for output via pdb_lines
            message(FATAL_ERROR "Unable to run dumpbin and findstr! Error code: ${error_code};${pdb_lines}")
        endif()
        if(pdb_lines)
            set(search_pdbs "${build_dbg_pdbs}")
            analyze_dumpbin_pdbs("${dll_or_exe}" search_pdbs pdb_lines "debug/")
            if(pdb_not_found)
                list(APPEND no_matching_pdbs "${dll_or_exe}")
            endif()
        endif()
    endforeach()

    set(ENV{VSLANG} "${vslang_backup}")

    if(NOT no_matching_pdbs STREQUAL "")
        list(REMOVE_DUPLICATES no_matching_pdbs)
        list(JOIN no_matching_pdbs "\n\t" msg)
        message(WARNING "Could not find a matching pdb file for:\n${msg}\n")
    endif()
endfunction()

z_vcpkg_copy_pdbs()