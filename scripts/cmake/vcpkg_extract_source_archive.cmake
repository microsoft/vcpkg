include(vcpkg_execute_required_process)

function(vcpkg_extract_source_archive ARCHIVE)
    get_filename_component(ARCHIVE_FILENAME ${ARCHIVE} NAME)
    if(NOT EXISTS ${CURRENT_BUILDTREES_DIR}/src/${ARCHIVE_FILENAME}.extracted)
        message(STATUS "Extracting source ${ARCHIVE}")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src)
        vcpkg_execute_required_process(
            COMMAND ${CMAKE_COMMAND} -E tar xjf ${ARCHIVE}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
            LOGNAME extract
        )
        file(WRITE ${CURRENT_BUILDTREES_DIR}/src/${ARCHIVE_FILENAME}.extracted)
    endif()
    message(STATUS "Extracting done")
endfunction()
