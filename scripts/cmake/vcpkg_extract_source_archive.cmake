include(vcpkg_execute_required_process)

function(vcpkg_extract_source_archive_ex)
    cmake_parse_arguments(_vesae "" "ARCHIVE;WORKING_DIRECTORY" "" ${ARGN})

    if(NOT _vesae_ARCHIVE)
        message(FATAL_ERROR "Must specify ARCHIVE parameter to vcpkg_extract_source_archive_ex()")
    endif()

    if(DEFINED _vesae_WORKING_DIRECTORY)
        set(WORKING_DIRECTORY ${_vesae_WORKING_DIRECTORY})
    else()
        set(WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src)
    endif()

    get_filename_component(ARCHIVE_FILENAME ${_vesae_ARCHIVE} NAME)
    if(NOT EXISTS ${WORKING_DIRECTORY}/${ARCHIVE_FILENAME}.extracted)
        message(STATUS "Extracting source ${_vesae_ARCHIVE}")
        file(MAKE_DIRECTORY ${WORKING_DIRECTORY})
        vcpkg_execute_required_process(
            COMMAND ${CMAKE_COMMAND} -E tar xjf ${_vesae_ARCHIVE}
            WORKING_DIRECTORY ${WORKING_DIRECTORY}
            LOGNAME extract
        )
        file(WRITE ${WORKING_DIRECTORY}/${ARCHIVE_FILENAME}.extracted)
    endif()
    message(STATUS "Extracting done")
endfunction()

function(vcpkg_extract_source_archive ARCHIVE)
    if(NOT ARGC EQUAL 2)
        vcpkg_extract_source_archive_ex(ARCHIVE ${ARCHIVE})
    else()
        vcpkg_extract_source_archive_ex(
            ARCHIVE ${ARCHIVE}
            WORKING_DIRECTORY ${ARGV1}
        )
    endif()
endfunction()