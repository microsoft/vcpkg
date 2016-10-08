include(vcpkg_execute_required_process)

function(vcpkg_extract_source_archive ARCHIVE)
    if(NOT ARGC EQUAL 2)
        set(WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src)
    else()
        set(WORKING_DIRECTORY ${ARGV1})
    endif()

    get_filename_component(ARCHIVE_FILENAME ${ARCHIVE} NAME)
    if(NOT EXISTS ${WORKING_DIRECTORY}/${ARCHIVE_FILENAME}.extracted)
        message(STATUS "Extracting source ${ARCHIVE}")
        file(MAKE_DIRECTORY ${WORKING_DIRECTORY})
        vcpkg_execute_required_process(
            COMMAND ${CMAKE_COMMAND} -E tar xjf ${ARCHIVE}
            WORKING_DIRECTORY ${WORKING_DIRECTORY}
            LOGNAME extract
        )
        file(WRITE ${WORKING_DIRECTORY}/${ARCHIVE_FILENAME}.extracted)
    endif()
    message(STATUS "Extracting done")
endfunction()
