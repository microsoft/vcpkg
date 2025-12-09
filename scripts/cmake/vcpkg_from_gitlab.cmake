include(vcpkg_execute_in_download_mode)

function(z_uri_encode input output_variable)
    string(HEX "${input}" hex)
    string(LENGTH "${hex}" length)
    math(EXPR last "${length} - 1")
    set(result "")
    foreach(i RANGE ${last})
        math(EXPR even "${i} % 2")
        if("${even}" STREQUAL "0")
            string(SUBSTRING "${hex}" "${i}" 2 char)
            string(APPEND result "%${char}")
        endif()
    endforeach()
    set("${output_variable}" ${result} PARENT_SCOPE)
endfunction()

function(vcpkg_from_gitlab)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;GITLAB_URL;REPO;REF;SHA512;HEAD_REF;FILE_DISAMBIGUATOR;AUTHORIZATION_TOKEN"
        "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_gitlab was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_GITLAB_URL)
        message(FATAL_ERROR "GITLAB_URL must be specified.")
    endif()

    if(DEFINED arg_REF AND NOT DEFINED arg_SHA512)
        message(FATAL_ERROR "SHA512 must be specified if REF is specified.")
    endif()
    if(NOT DEFINED arg_REF AND DEFINED arg_SHA512)
        message(FATAL_ERROR "REF must be specified if SHA512 is specified.")
    endif()

    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()
    if(NOT DEFINED arg_REPO)
        message(FATAL_ERROR "The GitHub repository must be specified.")
    endif()

    set(headers_param "")
    if(DEFINED arg_AUTHORIZATION_TOKEN)
        set(headers_param "HEADERS" "PRIVATE-TOKEN: ${arg_AUTHORIZATION_TOKEN}")
    endif()

    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "At least one of REF or HEAD_REF must be specified.")
    endif()

    if (NOT arg_REPO MATCHES [[^([^/;]+/)+([^/;]+)$]])
        message(FATAL_ERROR "REPO (${arg_REPO}) is not a valid repo name. It must be:
    - an organization name followed by a repository name separated by a single slash, or
    - an organization name, group name, subgroup names and repository name separated by slashes.")
    endif()
    set(gitlab_link "${arg_GITLAB_URL}/${arg_REPO}")
    string(REPLACE "/" "-" downloaded_file_name_base "${arg_REPO}")
    string(REPLACE "/" ";" repo_parts "${arg_REPO}")
    list(GET repo_parts -1 repo_name)

    set(redownload_param "")
    set(working_directory_param "")
    set(sha512_param "SHA512" "${arg_SHA512}")
    set(ref_to_use "${arg_REF}")
    if(VCPKG_USE_HEAD_VERSION)
        if(DEFINED arg_HEAD_REF)
            set(redownload_param "ALWAYS_REDOWNLOAD")
            set(sha512_param "SKIP_SHA512")
            set(working_directory_param "WORKING_DIRECTORY" "${CURRENT_BUILDTREES_DIR}/src/head")
            set(ref_to_use "${arg_HEAD_REF}")
        else()
            message(STATUS "Package does not specify HEAD_REF. Falling back to non-HEAD version.")
        endif()
    elseif(NOT DEFINED arg_REF)
        message(FATAL_ERROR "Package does not specify REF. It must be built using --head.")
    endif()

    # avoid using either - or _, to allow both `foo/bar` and `foo-bar` to coexist
    # we assume that no one will name a ref "foo_-bar"
    string(REPLACE "/" "_-" sanitized_ref "${ref_to_use}")
    if(DEFINED arg_FILE_DISAMBIGUATOR AND NOT VCPKG_USE_HEAD_VERSION)
        set(downloaded_file_name "${downloaded_file_name_base}-${sanitized_ref}-${arg_FILE_DISAMBIGUATOR}.tar.gz")
    else()
        set(downloaded_file_name "${downloaded_file_name_base}-${sanitized_ref}.tar.gz")
    endif()


    # exports VCPKG_HEAD_VERSION to the caller. This will get picked up by ports.cmake after the build.
    # When multiple vcpkg_from_gitlab's are used after each other, only use the version from the first (hopefully the primary one).
    if(VCPKG_USE_HEAD_VERSION AND NOT DEFINED VCPKG_HEAD_VERSION)
        z_uri_encode("${arg_REPO}" encoded_repo_path)
        set(version_url "${arg_GITLAB_URL}/api/v4/projects/${encoded_repo_path}/repository/branches/${arg_HEAD_REF}")
        vcpkg_download_distfile(archive_version
            URLS "${version_url}"
            FILENAME "${downloaded_file_name}.version"
            ${headers_param}
            SKIP_SHA512
            ALWAYS_REDOWNLOAD
        )
        # Parse the gitlab response with regex.
        file(READ "${archive_version}" version_contents)
        if(NOT version_contents MATCHES [["id":(\ *)"([a-f0-9]+)"]])
            message(FATAL_ERROR "Failed to parse API response from '${version_url}':\n${version_contents}\n")
        endif()
        set(VCPKG_HEAD_VERSION "${CMAKE_MATCH_2}" PARENT_SCOPE)
    endif()

    # download the file information from gitlab
    vcpkg_download_distfile(archive
        URLS "${gitlab_link}/-/archive/${ref_to_use}/${repo_name}-${ref_to_use}.tar.gz"
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
    )
    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
