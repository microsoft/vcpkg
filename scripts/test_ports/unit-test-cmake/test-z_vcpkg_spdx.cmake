string(ASCII 1 control_character)
string(ASCII 8 backspace)
string(ASCII 12 form_feed)
set(expected_name "name; with \"quotes\", \\slashes\\, /solidus, ${backspace}backspace, ${form_feed}form feed,\nnewlines,\rcarriage returns,\ttabs, and ${control_character}controls")
set(expected_filename "archive;\"name\".tar.gz")
set(expected_download_location "https://example.com/a;b?query=\"value\"")

set(expected_encoded_name [["name; with \"quotes\", \\slashes\\, /solidus, \bbackspace, \fform feed,\nnewlines,\rcarriage returns,\ttabs, and \u0001controls"]])
foreach(encoder IN ITEMS z_vcpkg_spdx_json_string_encode z_vcpkg_spdx_json_string_encode_compat)
    cmake_language(CALL "${encoder}" encoded_name "${expected_name}")
    if(NOT encoded_name STREQUAL expected_encoded_name)
        message(SEND_ERROR "${encoder} does not match string(JSON STRING_ENCODE):
    expected: ${expected_encoded_name}
    actual  : ${encoded_name}")
        set_has_error()
    endif()
endforeach()

set_property(GLOBAL PROPERTY Z_VCPKG_SPDX_OBJECTS "")
z_vcpkg_add_spdx_resource(
    NAME "${expected_name}"
    FILENAME "${expected_filename}"
    DOWNLOAD_LOCATION "${expected_download_location}"
)

get_property(resources GLOBAL PROPERTY Z_VCPKG_SPDX_OBJECTS)
vcpkg_list(GET resources 0 resource)
foreach(property IN ITEMS name packageFileName downloadLocation)
    string(JSON actual_value GET "${resource}" "${property}")
    if(property STREQUAL "name")
        set(expected_value "${expected_name}")
    elseif(property STREQUAL "packageFileName")
        set(expected_value "${expected_filename}")
    else()
        set(expected_value "${expected_download_location}")
    endif()

    if(NOT actual_value STREQUAL expected_value)
        message(SEND_ERROR "SPDX ${property} was encoded incorrectly:
    expected: \"${expected_value}\"
    actual  : \"${actual_value}\"")
        set_has_error()
    endif()
endforeach()
