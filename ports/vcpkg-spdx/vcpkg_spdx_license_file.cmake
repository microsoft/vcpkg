include_guard(GLOBAL)

function(z_vcpkg_spdx_license_list_data out_var)
    set(data_version v3.19)
    set(data_dir "${DOWNLOADS}/tools/spdx_license-list-data_${data_version}")
    if(NOT EXISTS "${data_dir}")
        vcpkg_download_distfile(data_archive
            URLS "https://github.com/spdx/license-list-data/archive/refs/tags/v3.19.tar.gz"
            FILENAME "spdx_license-list-data_${data_version}.tar.gz"
            SHA512 23d90eece2f164a00ad710c84c3f3194bf54830b4c2b5c2739c4bf713c95ab161697850eecb20d1c3dfbdad24aa795a75bf11f9473982824fc9fe885962b7433
        )
        vcpkg_extract_source_archive(source_path
            ARCHIVE "${data_archive}"
            WORKING_DIRECTORY "${DOWNLOADS}/tools"
        )
        file(RENAME "${source_path}" "${data_dir}")
    endif()
    set("${out_var}" "${data_dir}" PARENT_SCOPE)
endfunction()

function(vcpkg_spdx_license_file out_var)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "FORMAT" "NAMES")
    if("${arg_NAMES}" STREQUAL "")
        set(arg_NAMES "${ARGV0}")
    endif()
    if("${arg_FORMAT}" STREQUAL "")
        set(arg_FORMAT "text")
    endif()
    set(extension_html ".html")
    set(extension_json ".json")
    set(extension_jsonld ".jsonld")
    set(extension_rdfa ".html")
    set(extension_rdfnt ".nt")
    set(extension_rdfturtle ".ttl")
    set(extension_rdfxml ".rdf")
    set(extension_text ".txt")
    if(NOT DEFINED "extension_${arg_FORMAT}")
        message(FATAL_ERROR "Invalid format '${arg_FORMAT}'")
    endif()

    z_vcpkg_spdx_license_list_data(data_dir)
    list(TRANSFORM arg_NAMES APPEND "${extension_${arg_FORMAT}}" OUTPUT_VARIABLE filenames)
    find_file(file NAMES ${filenames} PATHS "${data_dir}/${arg_FORMAT}" PATH_SUFFIXES "details" "exceptions" NO_DEFAULT_PATH NO_CACHE REQUIRED)
    set("${out_var}" "${file}" PARENT_SCOPE)
endfunction()
