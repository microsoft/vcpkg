function(vcpkg_from_bitbucket)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_SOURCE_PATH;REPO;REF;SHA512;HEAD_REF"
        "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_from_bitbucket was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
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
        message(FATAL_ERROR "The Bitbucket repository must be specified.")
    endif()

    if(NOT DEFINED arg_REF AND NOT DEFINED arg_HEAD_REF)
        message(FATAL_ERROR "At least one of REF or HEAD_REF must be specified.")
    endif()

    if(NOT arg_REPO MATCHES "^([^/]*)/([^/]*)$")
        message(FATAL_ERROR "REPO (${arg_REPO}) is not a valid repo name:
    must be an organization name followed by a repository name separated by a single slash.")
    endif()
    set(org_name "${CMAKE_MATCH_1}")
    set(repo_name "${CMAKE_MATCH_2}")

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
    set(downloaded_file_name "${org_name}-${repo_name}-${sanitized_ref}.tar.gz")

    # exports VCPKG_HEAD_VERSION to the caller. This will get picked up by ports.cmake after the build.
    if(VCPKG_USE_HEAD_VERSION)
        vcpkg_download_distfile(archive_version
            URLS "https://api.bitbucket.com/2.0/repositories/${org_name}/${repo_name}/refs/branches/${arg_HEAD_REF}"
            FILENAME "${downloaded_file_name}.version"
            SKIP_SHA512
            ALWAYS_REDOWNLOAD
        )
        # Parse the github refs response with regex.
        # TODO: add json-pointer support to vcpkg
        file(READ "${archive_version}" version_contents)
        if(NOT version_contents MATCHES [["hash": "([a-f0-9]+)"]])
            message(FATAL_ERROR "Failed to parse API response from '${version_url}':

${version_contents}
")
        endif()
        set(VCPKG_HEAD_VERSION "${CMAKE_MATCH_1}" PARENT_SCOPE)
    endif()

    # download the file information from bitbucket.
    vcpkg_download_distfile(archive
        URLS "https://bitbucket.com/${org_name}/${repo_name}/get/${ref_to_use}.tar.gz"
        FILENAME "${downloaded_file_name}"
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
