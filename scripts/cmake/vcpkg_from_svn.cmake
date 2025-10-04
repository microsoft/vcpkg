function(z_vcpkg_parse_revision)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;SVN_COMMAND;OUT_VAR;WORKING_DIRECTORY"
        "PATCHES"
    )
        vcpkg_execute_in_download_mode(
            COMMAND ${arg_SVN_COMMAND} info
            OUTPUT_VARIABLE info_string 
            ERROR_VARIABLE info_string 
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
        )

        if(error_code)
            message(FATAL_ERROR "Unable to determine the revision from the svn repository. \
(svn info failed)")
        endif()
        if(info_string MATCHES "Last Changed Rev:[ \t]*([0-9]+)")
            vcpkg_list(SET revision ${CMAKE_MATCH_1})
            set("${arg_OUT_VAR}" "${revision}" PARENT_SCOPE)
        else()
            message(FATAL_ERROR "Unable to parse the svn revision for port ${PORT}.")
        endif()

endfunction()

function(vcpkg_from_svn)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "STDLAYOUT"
        "OUT_SOURCE_PATH;URL;REF;FETCH_REF;HEAD_REF;TRUNK;BRANCHES;TAGS"
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
    if(DEFINED arg_FETCH_REF AND NOT DEFINED arg_REF)
        message(FATAL_ERROR "REF must be specified if FETCH_REF is specified")
    endif()

    set(hash_archive "${arg_URL}")
    if(DEFINED arg_REF)
        string(APPEND hash_archive "-${arg_REF}-${arg_FETCH_REF}")
    else()
        string(APPEND hash_archive "-${arg_HEAD_REF}-${arg_REF}")
    endif()
    string(SHA1 hash_archive "${hash_archive}")
    string(SHA1 hash_url "${arg_URL}")

    vcpkg_list(SET extract_working_directory_param)
    vcpkg_list(SET skip_patch_check_param)
    vcpkg_list(SET svn_standard_layout_param)
    vcpkg_list(SET svn_trunk_param)
    vcpkg_list(SET svn_tags_param)
    vcpkg_list(SET svn_branches_param)
    vcpkg_list(SET branch_to_use "trunk")
    vcpkg_list(SET ref_to_fetch)
    vcpkg_list(SET git_svn_fetch_parent_param "--no-follow-parent")

    set(svn_working_directory "${DOWNLOADS}/git-svn-tmp-${hash_url}")
    set(do_download OFF)

    if(arg_STDLAYOUT)
            vcpkg_list(SET svn_standard_layout_param "--stdlayout")
    endif()
    if(DEFINED arg_TRUNK)
            vcpkg_list(SET svn_trunk_param "--trunk=${arg_TRUNK}")
    endif()
    if(DEFINED arg_BRANCHES)
            vcpkg_list(SET svn_branches_param "--trunk=${arg_BRANCHES}")
    endif()
    if(DEFINED arg_TAGS)
            vcpkg_list(SET svn_tags_param "--trunk=${arg_TAGS}")
    endif()

    if(VCPKG_USE_HEAD_VERSION AND DEFINED arg_HEAD_REF)
        vcpkg_list(SET working_directory_param "WORKING_DIRECTORY" "${CURRENT_BUILDTREES_DIR}/src/head")
        vcpkg_list(SET skip_patch_check_param SKIP_PATCH_CHECK)
        set(branch_to_use "${arg_HEAD_REF}")
        vcpkg_list(SET ref_to_fetch "0:HEAD")
        message(STATUS "Fetching all revisions from svn repository. This can take a while for large repositories.")
        set(svn_working_directory "${CURRENT_BUILDTREES_DIR}/src/git-svn-tmp-${hash_url}")
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

        if(DEFINED arg_FETCH_REF)
            set(branch_to_use "${arg_FETCH_REF}")
            vcpkg_list(SET ref_to_fetch "${arg_REF}")
        else()
            set(branch_to_use "trunk")
            vcpkg_list(SET ref_to_fetch "${arg_REF}")
        endif()
    endif()

    set(temp_archive "${DOWNLOADS}/temp/${PORT}-${hash_archive}.tar.gz")
    set(archive "${DOWNLOADS}/${PORT}-${hash_archive}.tar.gz")

    if(NOT EXISTS "${archive}")
        if(_VCPKG_NO_DOWNLOADS)
            message(FATAL_ERROR "Downloads are disabled, but '${archive}' does not exist.")
        endif()
        set(do_download ON)
    endif()

    if(do_download)
        message(STATUS "Fetching ${arg_URL} ${branch_to_use}...")
        find_program(GIT NAMES git git.cmd)
        vcpkg_list(SET SVN "${GIT}" -c init.defaultBranch=trunk svn)

        vcpkg_execute_in_download_mode(
            COMMAND ${SVN} --version
            OUTPUT_VARIABLE svn_version_output
            ERROR_VARIABLE svn_version_error
            RESULT_VARIABLE svn_version_result
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        )
        if(svn_version_result)
            message(FATAL_ERROR "git-svn is required for ${PORT}.")
        endif()

        file(MAKE_DIRECTORY "${DOWNLOADS}")

        # Note: git svn init is safe to run multiple times, if url is the same
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND ${SVN} init ${svn_standard_layout_param} ${svn_trunk_param}
            ${svn_branches_param} ${svn_tags_param}
            ${arg_URL} ${svn_working_directory} 
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "git-svn-init-${TARGET_TRIPLET}"
        )

        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND ${SVN} fetch ${git_svn_fetch_parent_param} --revision "${ref_to_fetch}"
            WORKING_DIRECTORY "${svn_working_directory}"
            LOGNAME "git-svn-fetch-${TARGET_TRIPLET}"
        )

        vcpkg_execute_in_download_mode(
            COMMAND ${GIT} switch --detach origin/${branch_to_use} 
            OUTPUT_VARIABLE git_svn_switch
            ERROR_VARIABLE git_svn_switch
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${svn_working_directory}"
        )

        if(error_code)
            message(FATAL_ERROR "Unable to switch to the svn branch origin/${branch_to_use}.\
Maybe the layout of the svn repository was not specifed correctly. (git svn switch --detach origin/${branch_to_use} failed)")
        endif()

        if(NOT VCPKG_USE_HEAD_VERSION)
            vcpkg_execute_in_download_mode(
                COMMAND ${SVN} find-rev "r${arg_REF}"
                OUTPUT_VARIABLE find_ref 
                ERROR_VARIABLE find_ref_err
                RESULT_VARIABLE error_code
                WORKING_DIRECTORY "${svn_working_directory}"
            )
            if(error_code)
                message(FATAL_ERROR "Could not find the specified revision ${arg_REF} in svn repository for port ${PORT}. \
(git svn find-rev r${arg_REF} failed)")
            endif()

            string(STRIP "${find_ref}" find_ref)
            vcpkg_execute_in_download_mode(
                COMMAND ${GIT} checkout "${find_ref}"
                OUTPUT_VARIABLE git_checkout_ref
                ERROR_VARIABLE git_checkout_ref 
                RESULT_VARIABLE error_code
                WORKING_DIRECTORY "${svn_working_directory}"
            )
            if(error_code)
                message(FATAL_ERROR "Could not checkout the revision ${find_ref} for port ${PORT}.\
It can help to delete the svn working directory manually. (git checkout ${find_ref} failed in ${svn_working_directory}!)")
            endif()
        endif()

        z_vcpkg_parse_revision( 
            SVN_COMMAND "${SVN}" 
            OUT_VAR rev_parse_ref
            WORKING_DIRECTORY "${svn_working_directory}"
        )

        string(STRIP "${rev_parse_ref}" rev_parse_ref)

        if(VCPKG_USE_HEAD_VERSION)
            set(VCPKG_HEAD_VERSION "${rev_parse_ref}" PARENT_SCOPE)
        elseif(NOT "${rev_parse_ref}" STREQUAL "${arg_REF}")
                message(FATAL_ERROR "After checkout ${branch_to_use}, the requested REV (${arg_REF}) does not match \
the revision matched by svn info. \
    [Expected : ( ${arg_REF} )]) \
    [  Actual : ( ${rev_parse_ref} )]"
            )
        endif()

        file(MAKE_DIRECTORY "${DOWNLOADS}/temp")
        # Always archive the current head
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" -c core.autocrlf=false archive "HEAD" -o "${temp_archive}"
            WORKING_DIRECTORY "${svn_working_directory}"
            LOGNAME git-archive
        )
        file(RENAME "${temp_archive}" "${archive}")
    else()
        message(STATUS "Using cached ${archive}")
    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${archive}"
        REF "${hash_archive}"
        PATCHES ${arg_PATCHES}
        NO_REMOVE_ONE_LEVEL
        ${extract_working_directory_param}
        ${skip_patch_check_param}
    )

    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
