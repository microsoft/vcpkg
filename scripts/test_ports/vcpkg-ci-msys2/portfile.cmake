set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(msys_repo_url    "https://mirror.msys2.org/msys/x86_64")
set(mingw64_repo_url "https://mirror.msys2.org/mingw/x86_64")

# Temporarily ignore these packages.
vcpkg_list(SET ignored_packages
    https://mirror.msys2.org/mingw/x86_64/mingw-w64-x86_64-ca-certificates-20211016-3-any.pkg.tar.zst
)

# Replace vcpkg name with msys2 names
set(substitute_autoconf autoconf2.71)
set(substitute_pkg-config pkgconf)
set(substitute_mingw-w64-x86_64-libtre mingw-w64-x86_64-libtre-git)
set(substitute_mingw-w64-x86_64-libwinpthread mingw-w64-x86_64-libwinpthread-git)

# A package may provide additional names, and vcpkg ignores some deps
function(process_deps list_name)
    set(list "${${list_name}}")
    list(REMOVE_ITEM list  info less libltdl mingw-w64-x86_64-tzdata)
    list(TRANSFORM list  REPLACE [[^sh$]] bash)
    list(SORT list)
    set(${list_name} "${list}" PARENT_SCOPE)
endfunction()

vcpkg_list(SET msys2_names)

# Parse z_vcpkg_acquire_msys_declare_package arguments into local parent-scope variables
function(parse_download_arguments)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "NAME;URL;SHA512" "DEPS;PATCHES")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "internal error: parse_download_arguments passed extra args: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS URL SHA512)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "internal error: z_vcpkg_acquire_msys_declare_package requires argument: ${required_arg}")
        endif()
    endforeach()
    if(NOT arg_URL MATCHES [[^https://mirror\.msys2\.org/.*/(([^-]+(-[^0-9][^-]*)*)-.+\.pkg\.tar\.(xz|zst))$]])
        message(FATAL_ERROR "internal error: regex does not match supplied URL to vcpkg_acquire_msys: ${arg_URL}")
    endif()
    set(filename "${CMAKE_MATCH_1}")
    if(NOT DEFINED arg_NAME)
        set(arg_NAME "${CMAKE_MATCH_2}")
    endif()

    z_vcpkg_acquire_msys_download_package(archive
        URL "${arg_URL}"
        SHA512 "${arg_SHA512}"
        FILENAME "${filename}"
    )

    vcpkg_list(APPEND msys2_names "${arg_NAME}")
    set(msys2_names "${msys2_names}" PARENT_SCOPE)
    set(msys2_url_${arg_NAME} "${arg_URL}" PARENT_SCOPE)
    set(msys2_sha512_${arg_NAME} "${arg_SHA512}" PARENT_SCOPE)
    set(msys2_deps_${arg_NAME} "${arg_DEPS}" PARENT_SCOPE)
    set(msys2_filename_${arg_NAME} "${filename}" PARENT_SCOPE)
    set(msys2_archive_${arg_NAME} "${archive}" PARENT_SCOPE)
endfunction()

function(get_builddate arg_NAME)
    set(pkginfo_dir "${CURRENT_BUILDTREES_DIR}/vcpkg")
    file(REMOVE_RECURSE "${pkginfo_dir}/${arg_NAME}.txt" "${pkginfo_dir}/_tmp")
    file(MAKE_DIRECTORY "${pkginfo_dir}/_tmp")
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E tar xzf "${msys2_archive_${arg_NAME}}" .PKGINFO
        WORKING_DIRECTORY "${pkginfo_dir}/_tmp"
    )
    file(RENAME "${pkginfo_dir}/_tmp/.PKGINFO" "${pkginfo_dir}/${arg_NAME}.txt")
    file(STRINGS "${pkginfo_dir}/${arg_NAME}.txt" builddate REGEX "builddate = [0-9]*")
    string(REPLACE "builddate = " "" builddate "${builddate}")
    set(msys2_builddate_${arg_NAME} "${builddate}" PARENT_SCOPE)
endfunction()

function(update_msys_download name new_url)
    message(STATUS "Updating vcpkg...")
    if(NOT new_url MATCHES [[^https://repo\.msys2\.org/.*/(([^-]+(-[^0-9][^-]*)*)-.+\.pkg\.tar\.(xz|zst))$]])
        message(FATAL_ERROR "internal error: regex does not match supplied URL to vcpkg_acquire_msys: ${arg_URL}")
    endif()
    set(filename "${CMAKE_MATCH_1}")
    vcpkg_download_distfile(archive
        URLS "${new_url}"
        FILENAME "${filename}"
        SKIP_SHA512
    )
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E sha512sum "${archive}"
        OUTPUT_VARIABLE sha512
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX REPLACE " .*" "" sha512 "${sha512}")
    vcpkg_replace_string("${SCRIPTS}/cmake/vcpkg_acquire_msys.cmake" "${msys2_url_${name}}" "${new_url}")
    vcpkg_replace_string("${SCRIPTS}/cmake/vcpkg_acquire_msys.cmake" "${msys2_sha512_${name}}" "${sha512}")
endfunction()

message(STATUS "+++ Collecting package list from vcpkg_acquire_msys.cmake")
file(READ "${SCRIPTS}/cmake/vcpkg_acquire_msys.cmake" vcpkg_acquire_msys)
string(REGEX REPLACE "#[^\r\n]*" "" vcpkg_acquire_msys "${vcpkg_acquire_msys}")
string(REGEX MATCHALL "z_vcpkg_acquire_msys_declare_package[(][^)]*" msys_downloads "${vcpkg_acquire_msys}")
string(REPLACE "z_vcpkg_acquire_msys_declare_package(" "" msys_downloads "${msys_downloads}")
foreach(param_list IN LISTS msys_downloads)
    cmake_language(EVAL CODE "parse_download_arguments(${param_list})")
endforeach()

message(STATUS "+++ Downloading current package lists")
string(TIMESTAMP stamp "%Y-%m" UTC)
foreach(repo IN ITEMS msys mingw64)
    string(REPLACE "/" "-" local_file "msys2-${stamp}-${repo}.files")
    set(archive "${DOWNLOADS}/${local_file}")
    if(NOT EXISTS "${DOWNLOADS}/${local_file}")
        set(repo_url "${${repo}_repo_url}/${repo}.files")
        set(all_urls "${repo_url}")
        foreach(mirror IN LISTS Z_VCPKG_ACQUIRE_MSYS_MIRRORS) # from vcpkg_acquire_msys2.cmake
            string(REPLACE "https://mirror.msys2.org/" "${mirror}" mirror_url "${repo_url}")
            list(APPEND all_urls "${mirror_url}")
        endforeach()
        vcpkg_download_distfile(archive
            URLS ${all_urls}
            FILENAME "${local_file}"
            SKIP_SHA512
        )
    endif()
    vcpkg_extract_source_archive(source_path
        ARCHIVE "${archive}"
        NO_REMOVE_ONE_LEVEL
    )
    set(${repo}_archive "${source_path}")
endforeach()


string(TIMESTAMP now "%s" UTC)
function(pretty_age out_var timestamp)
    if(timestamp)
        math(EXPR age "(${now} - ${timestamp}) / 3600 / 24")
        set(${out_var} "(${age} days ago)" PARENT_SCOPE)
    else()
        set(${out_var} "(timestamp unknown)" PARENT_SCOPE)
    endif()
endfunction()

message(STATUS "+++ Analyzing package lists")
vcpkg_list(SET critical)         # Packages which can be upgraded and are fairly old in vcpkg
vcpkg_list(SET mismatched_deps)  # Packages which have vcpkg deps different from msys2 deps
vcpkg_list(SET missing)          # Packages used in (new) deps but not declared
vcpkg_list(SET upgradable)       # Packages which can be upgrade but are fairly fresh in vcpkg
vcpkg_list(SET vanished)         # Packages which vanished from the msys2 database
string(TIMESTAMP now "%s" UTC)
math(EXPR minimum_builddate "${now} - 6 * 30 * 24 * 3600")
foreach(name IN LISTS msys2_names)
    message(STATUS "${name}")
    set(vcpkg_url "${msys2_url_${name}}")
    set(vcpkg_deps "${msys2_deps_${name}}")

    set(repo "msys")
    if(name MATCHES "^mingw-w64")
        set(repo "mingw64")
    endif()
    set(msys_name "${name}")
    if(DEFINED substitute_${name})
        set(msys_name "${substitute_${name}}")
    endif()

    file(GLOB files "${${repo}_archive}/${msys_name}-*/desc")
    set(found 0)
    foreach(file IN LISTS files)
        # Find the package
        file(STRINGS "${file}" desc)
        if(NOT desc MATCHES "%NAME%;${msys_name};")
            continue()
        elseif(NOT desc MATCHES "%FILENAME%;([^;]+)")
            continue()
        endif()
        set(current_url "${${repo}_repo_url}/${CMAKE_MATCH_1}")
        # Check the URL
        if(current_url IN_LIST ignored_packages)
            set(current_url "${vcpkg_url}") # allow other checks than url
        endif()
        if(NOT vcpkg_url STREQUAL current_url)
            get_builddate("${name}") # expensive
            set(vcpkg_builddate "${msys2_builddate_${name}}")
            pretty_age(vcpkg_age "${vcpkg_builddate}")
            if(desc MATCHES "%BUILDDATE%;([0-9]+)")
                pretty_age(current_age "${CMAKE_MATCH_1}")
            else()
                pretty_age(current_age "")
            endif()
            message(STATUS "- vcpkg: ${vcpkg_url} ${vcpkg_age}")
            message(STATUS "+ msys2: ${current_url} ${current_age}")
            string(REGEX REPLACE "-[0-9]+-x86_64[.]pkg[.]t.*$" "" vcpkg_base "${vcpkg_url}")
            string(REGEX REPLACE "-[0-9]+-x86_64[.]pkg[.]t.*$" "" current_base "${current_url}")
            # Check the builddates
            if(vcpkg_builddate AND vcpkg_builddate LESS minimum_builddate)
                if("update-critical" IN_LIST FEATURES)
                    update_msys_download("${name}" "${current_url}")
                else()
                    vcpkg_list(APPEND critical "${name}")
                endif()
            elseif(NOT vcpkg_builddate OR NOT vcpkg_base STREQUAL current_base)
                if("update-all" IN_LIST FEATURES)
                    update_msys_download("${name}" "${current_url}")
                else()
                    vcpkg_list(APPEND upgradable "${name}")
                endif()
            endif()
        endif()
        # Check the dependencies
        if(desc MATCHES "%DEPENDS%;([^%]*)" OR vcpkg_deps)
            list(JOIN CMAKE_MATCH_1 " " current_deps)
            separate_arguments(current_deps UNIX_COMMAND "${current_deps}")
            list(TRANSFORM current_deps REPLACE "[<=>].*" "")
            process_deps(current_deps)
            process_deps(vcpkg_deps)
            if(NOT vcpkg_deps STREQUAL current_deps)
                vcpkg_list(APPEND mismatched_deps "${name}")
                message(STATUS "- vcpkg deps: ${vcpkg_deps}")
                message(STATUS "+ msys2 deps: ${current_deps}")
                list(REMOVE_ITEM current_deps ${msys2_names})
                if(current_deps)
                    message(STATUS "! unknown deps: ${current_deps}")
                    vcpkg_list(APPEND missing ${current_deps})
                endif()
            endif()
        endif()
        set(found 1)
    endforeach()
    if(NOT found)
        vcpkg_list(APPEND vanished "${name}")
        get_builddate("${name}") # expensive
        pretty_age(vcpkg_age "${msys2_builddate_${name}}")
        message(STATUS "- vcpkg: ${vcpkg_url} ${vcpkg_age}")
        message(STATUS "! msys2: no match for ${name}")
    endif()
endforeach()

if(mismatched_deps)
    list(JOIN mismatched_deps " " mismatched_deps)
    message(WARNING "The following msys2 packages have changed dependencies: ${mismatched_deps}")
endif()
if(missing)
    list(SORT missing)
    list(REMOVE_DUPLICATES missing)
    list(JOIN missing " " missing)
    message(WARNING "The following msys2 packages would be needed to update all dependencies: ${missing}")
endif()
if(upgradable)
    list(JOIN upgradable " " upgradable)
    message(WARNING "The following msys2 packages could be updated: ${upgradable}")
endif()
if(critical)
    list(JOIN critical " " critical)
    message(SEND_ERROR "The following msys2 packages were build more than 6 months ago and should be updated: ${critical}")
endif()
if(vanished)
    list(JOIN vanished " " vanished)
    message(SEND_ERROR "The following msys2 packages are no longer in the database: ${vanished}")
endif()
