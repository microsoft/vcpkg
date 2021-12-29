#[===[.md:
# vcpkg_from_sourceforge

Download and extract a project from sourceforge.

This function automatically checks a set of sourceforge mirrors.
Additional mirrors can be injected through the `VCPKG_SOURCEFORGE_EXTRA_MIRRORS`
list variable in the triplet.

## Usage:
```cmake
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO <cunit/CUnit>
    [REF <2.1-3>]
    SHA512 <547b417109332...>
    FILENAME <CUnit-2.1-3.tar.bz2>
    [DISABLE_SSL]
    [NO_REMOVE_ONE_LEVEL]
    [PATCHES <patch1.patch> <patch2.patch>...]
)
```

## Parameters:
### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### REPO
The organization or user and repository (optional) on sourceforge.

### REF
A stable version number that will not change contents.

### FILENAME
The local name for the file. Files are shared between ports, so the file may need to be renamed to make it clearly attributed to this port and avoid conflicts.

For example, we can get the download link:
https://sourceforge.net/settings/mirror_choices?projectname=mad&filename=libmad/0.15.1b/libmad-0.15.1b.tar.gz&selected=nchc
So the REPO is `mad/libmad`, the REF is `0.15.1b`, and the FILENAME is `libmad-0.15.1b.tar.gz`

For some special links:
https://sourceforge.net/settings/mirror_choices?projectname=soxr&filename=soxr-0.1.3-Source.tar.xz&selected=nchc
The REPO is `soxr`, REF is not exist, and the FILENAME is `soxr-0.1.3-Source.tar.xz`

### SHA512
The SHA512 hash that should match the archive.

This is most easily determined by first setting it to `0`, then trying to build the port. The error message will contain the full hash, which can be copied back into the portfile.

### WORKING_DIRECTORY
If specified, the archive will be extracted into the working directory instead of `${CURRENT_BUILDTREES_DIR}/src/`.

Note that the archive will still be extracted into a subfolder underneath that directory (`${WORKING_DIRECTORY}/${REF}-${HASH}/`).

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

### NO_REMOVE_ONE_LEVEL
Specifies that the default removal of the top level folder should not occur.

## Examples:

* [cunit](https://github.com/Microsoft/vcpkg/blob/master/ports/cunit/portfile.cmake)
* [polyclipping](https://github.com/Microsoft/vcpkg/blob/master/ports/polyclipping/portfile.cmake)
* [tinyfiledialogs](https://github.com/Microsoft/vcpkg/blob/master/ports/tinyfiledialogs/portfile.cmake)
#]===]

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
