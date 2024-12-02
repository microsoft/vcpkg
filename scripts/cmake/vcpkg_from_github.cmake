function(vcpkg_from_github)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;REPO;REF;SHA512;HEAD_REF;GITHUB_HOST;AUTHORIZATION_TOKEN;FILE_DISAMBIGUATOR"
        "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_github was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    unset(explicit_commit_tag)
    if(DEFINED arg_REF)
        set(_hex_char "[0-9a-fA-F]")
        string(REPEAT "${_hex_char}" 40 _hex40)
        if(arg_REF MATCHES "^${_hex40}\$")
            set(explicit_commit_tag "${arg_REF}")
        elseif(arg_REF MATCHES "^refs/")
            message(FATAL_ERROR "Ambiguous git refs, the REF argument should not start with 'refs/'.")
        else()
            set(explicit_commit_tag "refs/tags/${arg_REF}")
        endif()
    endif()

    if(DEFINED explicit_commit_tag AND NOT DEFINED arg_SHA512)
        message(FATAL_ERROR "SHA512 must be specified if REF is specified.")
    endif()
    if(NOT DEFINED explicit_commit_tag AND DEFINED arg_SHA512)
        message(FATAL_ERROR "REF must be specified if SHA512 is specified.")
    endif()

    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()
    if(NOT DEFINED arg_REPO)
        message(FATAL_ERROR "The GitHub repository must be specified.")
    endif()

    if(NOT DEFINED arg_GITHUB_HOST)
        set(github_host "https://github.com")
        set(github_api_url "https://api.github.com")
    else()
        set(github_host "${arg_GITHUB_HOST}")
        set(github_api_url "${arg_GITHUB_HOST}/api/v3")
    endif()

    set(headers_param "")
    if(DEFINED arg_AUTHORIZATION_TOKEN)
        set(headers_param "HEADERS" "Authorization: token ${arg_AUTHORIZATION_TOKEN}")
    endif()


    if(NOT DEFINED explicit_commit_tag AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "At least one of REF or HEAD_REF must be specified.")
    endif()

    if(NOT arg_REPO MATCHES "^([^/]*)/([^/]*)$")
        message(FATAL_ERROR "REPO (${arg_REPO}) is not a valid repo name:
    must be an organization name followed by a repository name separated by a single slash.")
    endif()
    set(org_name "${CMAKE_MATCH_1}")
    set(repo_name "${CMAKE_MATCH_2}")

    if(VCPKG_USE_HEAD_VERSION AND NOT DEFINED arg_HEAD_REF)
        message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        set(VCPKG_USE_HEAD_VERSION OFF)
    elseif(NOT VCPKG_USE_HEAD_VERSION AND NOT DEFINED explicit_commit_tag)
        message(FATAL_ERROR "Package does not specify REF. It must be built using --head.")
    endif()

    # exports VCPKG_HEAD_VERSION to the caller. This will get picked up by ports.cmake after the build.
    if(VCPKG_USE_HEAD_VERSION)
        string(REPLACE "/" "_-" sanitized_head_ref "${arg_HEAD_REF}")
        vcpkg_download_distfile(archive_version
            URLS "${github_api_url}/repos/${org_name}/${repo_name}/git/refs/heads/${arg_HEAD_REF}"
            FILENAME "${org_name}-${repo_name}-${sanitized_head_ref}.version"
            ${headers_param}
            SKIP_SHA512
            ALWAYS_REDOWNLOAD
        )
        # Parse the github refs response with regex.
        file(READ "${archive_version}" version_contents)
        string(JSON head_version
            ERROR_VARIABLE head_version_err
            GET "${version_contents}"
            "object"
            "sha"
        )
        if(NOT "${head_version_err}" STREQUAL "NOTFOUND")
            message(FATAL_ERROR "Failed to parse API response from '${version_url}':
${version_contents}

Error was: ${head_version_err}
")
        endif()

        set(VCPKG_HEAD_VERSION "${head_version}" PARENT_SCOPE)
        set(ref_to_use "${head_version}")

        vcpkg_list(SET redownload_param ALWAYS_REDOWNLOAD)
        vcpkg_list(SET sha512_param SKIP_SHA512)
        vcpkg_list(SET working_directory_param WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/head")
        vcpkg_list(SET skip_patch_check_param SKIP_PATCH_CHECK)
    else()
        set(ref_to_use "${explicit_commit_tag}")

        vcpkg_list(SET redownload_param)
        vcpkg_list(SET working_directory_param)
        vcpkg_list(SET skip_patch_check_param)
        vcpkg_list(SET sha512_param SHA512 "${arg_SHA512}")
    endif()

    string(REPLACE "/" "_-" sanitized_ref "${ref_to_use}")
    if(DEFINED arg_FILE_DISAMBIGUATOR AND NOT VCPKG_USE_HEAD_REF)
        set(downloaded_file_name "_temp-check-${org_name}-${repo_name}-${sanitized_ref}-${arg_FILE_DISAMBIGUATOR}.tar.gz")
    else()
        set(downloaded_file_name "_temp-check-${org_name}-${repo_name}-${sanitized_ref}.tar.gz")
    endif()
    # Try to download the file information from github
    vcpkg_download_distfile(archive
        URLS "https://codeload.github.com/${org_name}/${repo_name}/tar.gz/${ref_to_use}"
        # URLS "${github_host}/${org_name}/${repo_name}/archive/${ref_to_use}.tar.gz"
        FILENAME "${downloaded_file_name}"
        ${headers_param}
        ${sha512_param}
        ${redownload_param}
    )
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${archive}"
        REF "${sanitized_ref}"
        PATCHES ${arg_PATCHES}
        ${working_directory_param}
        ${skip_patch_check_param}
    )
    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
