function(z_vcpkg_add_spdx_resource)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "NAME;DOWNLOAD_LOCATION;SHA512;FILENAME"
        "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "z_vcpkg_add_spdx_resource was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    get_property(Z_VCPKG_SPDX_OBJECTS GLOBAL PROPERTY Z_VCPKG_SPDX_OBJECTS)
    list(LENGTH Z_VCPKG_SPDX_OBJECTS resource_index)
    set(resource "{}")

    string(JSON resource SET "${resource}" "SPDXID" "\"SPDXRef-resource-${resource_index}\"")
    string(JSON value STRING_ENCODE "${arg_NAME}")
    string(JSON resource SET "${resource}" "name" "${value}")
    if(DEFINED arg_FILENAME)
        string(JSON value STRING_ENCODE "${arg_FILENAME}")
        string(JSON resource SET "${resource}" "packageFileName" "${value}")
    endif()
    string(JSON value STRING_ENCODE "${arg_DOWNLOAD_LOCATION}")
    string(JSON resource SET "${resource}" "downloadLocation" "${value}")
    foreach(property IN ITEMS licenseConcluded licenseDeclared copyrightText)
        string(JSON resource SET "${resource}" "${property}" [["NOASSERTION"]])
    endforeach()

    if(DEFINED arg_SHA512 AND NOT "${arg_SHA512}" STREQUAL "")
        string(TOLOWER "${arg_SHA512}" sha512)
        string(JSON checksum SET "{}" "algorithm" [["SHA512"]])
        string(JSON checksum SET "${checksum}" "checksumValue" "\"${sha512}\"")
        string(JSON checksums SET "[]" 0 "${checksum}")
        string(JSON resource SET "${resource}" "checksums" "${checksums}")
    endif()

    vcpkg_list(APPEND Z_VCPKG_SPDX_OBJECTS "${resource}")
    set_property(GLOBAL PROPERTY Z_VCPKG_SPDX_OBJECTS "${Z_VCPKG_SPDX_OBJECTS}")
endfunction()
