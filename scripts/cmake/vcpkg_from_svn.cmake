function(z_vcpkg_parse_revision)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "URL;SVN_COMMAND;OUT_VAR"
        ""
    )
        vcpkg_execute_in_download_mode(
            COMMAND "${arg_SVN_COMMAND}" info "${arg_URL}"
            OUTPUT_VARIABLE info_string 
            ERROR_VARIABLE info_string 
            RESULT_VARIABLE error_code
        )

        if(error_code)
            message(FATAL_ERROR "Unable to determine the revision from the svn repository. \
(svn info failed)")
        endif()
        if(info_string MATCHES "Last Changed Rev:[ \t]*([0-9]+)")
            vcpkg_list(SET revision ${CMAKE_MATCH_1})
            set("${arg_OUT_VAR}" "${revision}" PARENT_SCOPE)
        else()
            message(FATAL_ERROR "Unable to parse the revision.")
        endif()

endfunction()

function(vcpkg_from_svn)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;URL;REF;HEAD_REF;IGNORE_EXTERNALS"
        "PATCHES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_svn was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified")
    endif()
    if(NOT DEFINED arg_URL)
        message(FATAL_ERROR "URL must be specified")
    endif()
    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "At least one of REF or HEAD_REF must be specified")
    endif()

    string(SHA256 url_hash "${arg_URL}")

    vcpkg_list(SET extract_working_directory_param)
    vcpkg_list(SET skip_patch_check_param)
    vcpkg_list(SET svn_ignore_externals_param)
    vcpkg_list(SET svn_depth_param --depth infinity)
    set(svn_working_directory "${DOWNLOADS}/svn-${url_hash}")
    set(do_download OFF)
    if(DEFINED IGNORE_EXTERNALS)
        vcpkg_list(SET "svn_ignore_externals_param" --ignore-externals)
    endif()

    if(VCPKG_USE_HEAD_VERSION AND DEFINED arg_HEAD_REF)
        vcpkg_list(SET working_directory_param "WORKING_DIRECTORY" "${CURRENT_BUILDTREES_DIR}/src/head")
        vcpkg_list(SET skip_patch_check_param SKIP_PATCH_CHECK)
        set(arg_URL "${arg_URL}/${arg_HEAD_REF}")
        z_vcpkg_parse_revision(
            URL "${arg_URL}" SVN_COMMAND "${svn}" OUT_VAR ref_to_fetch)
        set(arg_REF ${ref_to_fetch})
        string(REPLACE "/" "_-" sanitized_ref "${arg_REF}")

        if(NOT _VCPKG_NO_DOWNLOADS)
            set(do_download ON)
        endif()
    else()
        if(NOT DEFINED arg_REF)
            message(FATAL_ERROR "Package does not specify REF. It must be built using --head.")
        endif()
        if(VCPKG_USE_HEAD_VERSION)
            message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        endif()

        set(ref_to_fetch "${arg_REF}")
        string(REPLACE "/" "_-" sanitized_ref "${arg_REF}")
    endif()

    set(temp_archive "${DOWNLOADS}/temp/${PORT}-${url_hash}-${sanitized_ref}.tar.gz")
    set(archive "${DOWNLOADS}/${PORT}-${url_hash}-${sanitized_ref}.tar.gz")

    if(NOT EXISTS "${archive}")
        if(_VCPKG_NO_DOWNLOADS)
            message(FATAL_ERROR "Downloads are disabled, but '${archive}' does not exist.")
        endif()
        set(do_download ON)
    endif()

    if(do_download)
        message(STATUS "Fetching ${arg_URL} ${ref_to_fetch}...")
        find_program(SVN NAMES svn svn.cmd)
        file(MAKE_DIRECTORY "${DOWNLOADS}")
        # Note: git init is safe to run multiple times
        if(VCPKG_USE_HEAD_VERSION)
            set(expected_rev_parse HEAD)
        else(rev_parse_ref)
            set(expected_rev_parse "${arg_REF}")
        endif()

        file(REMOVE_RECURSE "${svn_working_directory}")
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${SVN}" checkout "--force"  -r "${ref_to_fetch}" ${svn_depth_param}
              ${svn_ignore_externals_param} ${arg_URL} ${svn_working_directory}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "svn-checkout-${TARGET_TRIPLET}"
        )

        z_vcpkg_parse_revision(URL "${svn_working_directory}" SVN_COMMAND "${svn}" OUT_VAR rev_parse_ref)

        string(STRIP "${rev_parse_ref}" rev_parse_ref)
        if(NOT "${rev_parse_ref}" STREQUAL "${arg_REF}")
                message(FATAL_ERROR "After checkout ${ref_to_fetch}, the requested REV (${arg_REF}) does not match \
the revision matched by svn info. \
    [Expected : ( ${arg_REF} )]) \
    [  Actual : ( ${rev_parse_ref} )]"
            )
        endif()

        file(MAKE_DIRECTORY "${DOWNLOADS}/temp")
        file(GLOB source_files "${svn_working_directory}/*")
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${CMAKE_COMMAND}" -E tar "cvf" "${temp_archive}" -- ${source_files}
            WORKING_DIRECTORY "${svn_working_directory}"
            LOGNAME svn-archive
        )
        file(RENAME "${temp_archive}" "${archive}")
    else()
        message(STATUS "Using cached ${archive}")
    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${archive}"
        REF "${sanitized_ref}"
        PATCHES ${arg_PATCHES}
        NO_REMOVE_ONE_LEVEL
        ${extract_working_directory_param}
        ${skip_patch_check_param}
    )

    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
