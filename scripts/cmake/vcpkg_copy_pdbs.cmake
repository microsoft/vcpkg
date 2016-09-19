function(vcpkg_copy_pdbs)
    function(merge_filelist OUTVAR INVAR)
        set(MSG "")
        foreach(VAR ${${INVAR}})
            set(MSG "${MSG}    ${VAR}\n")
        endforeach()
        set(${OUTVAR} ${MSG} PARENT_SCOPE)
    endfunction()

    file(GLOB_RECURSE DLLS ${CURRENT_PACKAGES_DIR}/bin/*.dll ${CURRENT_PACKAGES_DIR}/debug/bin/*.dll)

    set(DLLS_WITHOUT_MATCHING_PDBS)

    foreach(DLL ${DLLS})
        execute_process(COMMAND dumpbin /PDBPATH ${DLL}
                        COMMAND findstr PDB
            OUTPUT_VARIABLE PDB_LINE
            ERROR_QUIET
            RESULT_VARIABLE error_code
        )

        if(NOT error_code AND PDB_LINE MATCHES "PDB file found at")
       		string(REGEX MATCH '.*' PDB_PATH ${PDB_LINE}) # Extract the path which is in single quotes
       		string(REPLACE ' "" PDB_PATH ${PDB_PATH}) # Remove single quotes
       		get_filename_component(DLL_DIR ${DLL} DIRECTORY)
       		file(COPY ${PDB_PATH} DESTINATION ${DLL_DIR})
        else()
        	list(APPEND DLLS_WITHOUT_MATCHING_PDBS ${DLL})
        endif()
    endforeach()

    list(LENGTH DLLS_WITHOUT_MATCHING_PDBS UNMATCHED_DLLS_LENGTH)
    if(UNMATCHED_DLLS_LENGTH GREATER 0)
    	merge_filelist(MSG DLLS_WITHOUT_MATCHING_PDBS)
    	message(STATUS "Warning: Could not find a matching pdb file for:\n${MSG}")
    endif()

endfunction()