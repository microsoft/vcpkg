function(vcpkg_download_sourceforge out_var)
    cmake_parse_arguments(PARSE_ARGV 1 "arg"
        ""
        "REPO;REF;SHA512;FILENAME"
        "")

    foreach(arg_name IN ITEMS REPO SHA512 FILENAME)
        if(NOT DEFINED "arg_${arg_name}")
            message(FATAL_ERROR "${arg_name} is required.")
        endif()
    endforeach()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
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
    
    vcpkg_download_distfile(archive
        URLS ${all_urls}
        SHA512 "${arg_SHA512}"
        FILENAME "${arg_FILENAME}"
    )

    set("${out_var}" "${archive}" PARENT_SCOPE)
endfunction()
