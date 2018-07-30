## # vcpkg_extract_source_archive
##
## Extract an archive into the source directory.
##
## ## Usage
## ```cmake
## vcpkg_extract_source_archive(
##     <${ARCHIVE}> [<${TARGET_DIRECTORY}>]
## )
## ```
## ## Parameters
## ### ARCHIVE
## The full path to the archive to be extracted.
##
## This is usually obtained from calling [`vcpkg_download_distfile`](vcpkg_download_distfile.md).
##
## ### TARGET_DIRECTORY
## If specified, the archive will be extracted into the target directory instead of `${CURRENT_BUILDTREES_DIR}\src\`.
##
## This can be used to mimic git submodules, by extracting into a subdirectory of another archive.
##
## ## Notes
## This command will also create a tracking file named <FILENAME>.extracted in the TARGET_DIRECTORY. This file, when present, will suppress the extraction of the archive.
##
## ## Examples
##
## * [libraw](https://github.com/Microsoft/vcpkg/blob/master/ports/libraw/portfile.cmake)
## * [protobuf](https://github.com/Microsoft/vcpkg/blob/master/ports/protobuf/portfile.cmake)
## * [msgpack](https://github.com/Microsoft/vcpkg/blob/master/ports/msgpack/portfile.cmake)
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