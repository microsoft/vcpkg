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

function(vcpkg_extract_source_archive ARCHIVE)
    if(NOT ARGC EQUAL 2)
        set(WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src")
    else()
        set(WORKING_DIRECTORY ${ARGV1})
    endif()

    get_filename_component(ARCHIVE_FILENAME "${ARCHIVE}" NAME)
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
endfunction()

function(vcpkg_extract_source_archive_ex)
    cmake_parse_arguments(_vesae "NO_REMOVE_ONE_LEVEL" "OUT_SOURCE_PATH;ARCHIVE;REF;WORKING_DIRECTORY" "PATCHES" ${ARGN})

    if(NOT _vesae_ARCHIVE)
        message(FATAL_ERROR "Must specify ARCHIVE parameter to vcpkg_extract_source_archive_ex()")
    endif()

    if(NOT DEFINED _vesae_OUT_SOURCE_PATH)
        message(FATAL_ERROR "Must specify OUT_SOURCE_PATH parameter to vcpkg_extract_source_archive_ex()")
    endif()

    if(NOT DEFINED _vesae_WORKING_DIRECTORY)
        set(_vesae_WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src)
    endif()

    if(NOT DEFINED _vesae_REF)
        get_filename_component(_vesae_REF ${_vesae_ARCHIVE} NAME_WE)
    endif()

    string(REPLACE "/" "-" SANITIZED_REF "${_vesae_REF}")

    # Take the last 10 chars of the REF
    set(REF_MAX_LENGTH 10)
    string(LENGTH ${SANITIZED_REF} REF_LENGTH)
    math(EXPR FROM_REF ${REF_LENGTH}-${REF_MAX_LENGTH})
    if(FROM_REF LESS 0)
        set(FROM_REF 0)
    endif()
    string(SUBSTRING ${SANITIZED_REF} ${FROM_REF} ${REF_LENGTH} SHORTENED_SANITIZED_REF)

    # Hash the archive hash along with the patches. Take the first 10 chars of the hash
    file(SHA512 ${_vesae_ARCHIVE} PATCHSET_HASH)
    foreach(PATCH IN LISTS _vesae_PATCHES)
        get_filename_component(ABSOLUTE_PATCH "${PATCH}" ABSOLUTE BASE_DIR "${CURRENT_PORT_DIR}")
        file(SHA512 ${ABSOLUTE_PATCH} CURRENT_HASH)
        string(APPEND PATCHSET_HASH ${CURRENT_HASH})
    endforeach()

    string(SHA512 PATCHSET_HASH ${PATCHSET_HASH})
    string(SUBSTRING ${PATCHSET_HASH} 0 10 PATCHSET_HASH)
    set(SOURCE_PATH "${_vesae_WORKING_DIRECTORY}/${SHORTENED_SANITIZED_REF}-${PATCHSET_HASH}")

    if(NOT EXISTS ${SOURCE_PATH})
        set(TEMP_DIR "${_vesae_WORKING_DIRECTORY}/TEMP")
        file(REMOVE_RECURSE ${TEMP_DIR})
        vcpkg_extract_source_archive("${_vesae_ARCHIVE}" "${TEMP_DIR}")

        if(_vesae_NO_REMOVE_ONE_LEVEL)
            set(TEMP_SOURCE_PATH ${TEMP_DIR})
        else()
            file(GLOB _ARCHIVE_FILES "${TEMP_DIR}/*")
            list(LENGTH _ARCHIVE_FILES _NUM_ARCHIVE_FILES)
            set(TEMP_SOURCE_PATH)
            foreach(dir IN LISTS _ARCHIVE_FILES)
                if (IS_DIRECTORY ${dir})
                    set(TEMP_SOURCE_PATH "${dir}")
                    break()
                endif()
            endforeach()

            if(NOT _NUM_ARCHIVE_FILES EQUAL 2 OR NOT TEMP_SOURCE_PATH)
                message(FATAL_ERROR "Could not unwrap top level directory from archive. Pass NO_REMOVE_ONE_LEVEL to disable this.")
            endif()
        endif()

        vcpkg_apply_patches(
            SOURCE_PATH ${TEMP_SOURCE_PATH}
            PATCHES ${_vesae_PATCHES}
        )

        file(RENAME ${TEMP_SOURCE_PATH} ${SOURCE_PATH})
        file(REMOVE_RECURSE ${TEMP_DIR})
    endif()

    set(${_vesae_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
    message(STATUS "Using source at ${SOURCE_PATH}")
    return()
endfunction()
