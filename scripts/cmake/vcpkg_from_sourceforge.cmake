function(vcpkg_from_sourceforge)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "DISABLE_SSL;NO_REMOVE_ONE_LEVEL"
        "OUT_SOURCE_PATH;REPO;REF;SHA512;FILENAME;WORKING_DIRECTORY"
        "PATCHES")

    if(NOT DEFINED arg_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()
    if(NOT DEFINED arg_SHA512)
        message(FATAL_ERROR "SHA512 must be specified.")
    endif()
    if(NOT DEFINED arg_REPO)
        message(FATAL_ERROR "The sourceforge repository must be specified.")
    endif()


    if(arg_DISABLE_SSL)
        message(WARNING "DISABLE_SSL has been deprecated and has no effect")
    endif()
    
    set(sourceforge_host "https://sourceforge.net/projects")

    if(arg_REPO MATCHES "^([^/]*)$") # just one element
        set(org_name "${CMAKE_MATCH_1}")
        set(repo_name "")
    elseif(arg_REPO MATCHES "^([^/]*)/([^/]*)$") # two elements
        set(org_name "${CMAKE_MATCH_1}")
        set(repo_name "${CMAKE_MATCH_2}")
    else()
        message(FATAL_ERROR "REPO (${arg_REPO}) is not a valid repo name. It must be:
    - an organization name without any slashes, or
    - an organization name followed by a repository name separated by a single slash")
    endif()
    
    if(DEFINED arg_REF)
        set(url "${sourceforge_host}/${org_name}/files/${repo_name}/${arg_REF}/${arg_FILENAME}")
    elseif(DEFINED repo_name)
        set(url "${sourceforge_host}/${org_name}/${repo_name}/files/${arg_FILENAME}")
    else()
        set(url "${sourceforge_host}/${org_name}/files/${arg_FILENAME}")
    endif()
        
    string(SUBSTRING "${arg_SHA512}" 0 10 sanitized_ref)

    set(sourceforge_mirrors
        cfhcable        # United States
        pilotfiber      # New York, NY
        gigenet         # Chicago, IL
        versaweb        # Las Vegas, NV
        ayera           # Modesto, CA
        netactuate      # Durham, NC
        phoenixnap      # Tempe, AZ
        astuteinternet  # Vancouver, BC
        freefr          # Paris, France
        netcologne      # Cologne, Germany
        deac-riga       # Latvia
        excellmedia     # Hyderabad, India
        iweb            # Montreal, QC
        jaist           # Nomi, Japan
        jztkft          # Mezotur, Hungary
        managedway      # Detroit, MI
        nchc            # Taipei, Taiwan
        netix           # Bulgaria
        ufpr            # Curitiba, Brazil
        tenet           # Wynberg, South Africa
    )
    if(DEFINED SOURCEFORGE_MIRRORS AND NOT DEFINED VCPKG_SOURCEFORGE_EXTRA_MIRRORS)
        message(WARNING "Extension point SOURCEFORGE_MIRRORS has been deprecated.
    Please use the replacement VCPKG_SOURCEFORGE_EXTRA_MIRRORS variable instead.")
        list(APPEND sourceforge_mirrors "${SOURCEFORGE_MIRRORS}")
        list(REMOVE_DUPLICATES sourceforge_mirrors)
    elseif(DEFINED VCPKG_SOURCEFORGE_EXTRA_MIRRORS)
        list(APPEND sourceforge_mirrors "${VCPKG_SOURCEFORGE_EXTRA_MIRRORS}")
        list(REMOVE_DUPLICATES sourceforge_mirrors)
    endif()

    set(all_urls "${url}/download")
    foreach(mirror IN LISTS sourceforge_mirrors)
        list(APPEND all_urls "${url}/download?use_mirror=${mirror}")
    endforeach()
    
    vcpkg_download_distfile(ARCHIVE
        URLS ${all_urls}
        SHA512 "${arg_SHA512}"
        FILENAME "${arg_FILENAME}"
    )

    set(no_remove_one_level_param "")
    set(working_directory_param "")
    if(arg_NO_REMOVE_ONE_LEVEL)
        set(no_remove_one_level_param "NO_REMOVE_ONE_LEVEL")
    endif()
    if(DEFINED arg_WORKING_DIRECTORY)
        set(working_directory_param "WORKING_DIRECTORY" "${arg_WORKING_DIRECTORY}")
    endif()
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${ARCHIVE}"
        REF "${sanitized_ref}"
        ${no_remove_one_level_param}
        ${working_directory_param}
        PATCHES ${arg_PATCHES}
    )

    set("${arg_OUT_SOURCE_PATH}" "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()
