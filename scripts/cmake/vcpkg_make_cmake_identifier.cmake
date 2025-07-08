# Convert the input to a valid CMake identifier by replacing invalid characters with '_'. Useful when you want to create
# a map of some arbitrary length, based on user input that may contain invalid characters.
# Example use case: Map filenames to a boolean (stripping extensions would result in collisions)
# vcpkg_make_cmake_identifier(INPUT "my-project.exe" OUTPUT_VARIABLE identifier)
# set(map_${identifier}_to_bool TRUE) -> map_my-project_exe_to_bool: TRUE
# vcpkg_make_cmake_identifier(INPUT "my-project.conf" OUTPUT_VARIABLE identifier)
# set(map_${identifier}_to_bool FALSE) -> map_my-project_conf_to_bool: FALSE
#
# param INPUT - string, required. The input string to be converted
# param OUTPUT_VARIABLE - string, required. The output variable to store the converted identifier
function(vcpkg_make_cmake_identifier)

    set(one_value_args_ INPUT OUTPUT_VARIABLE)
    cmake_parse_arguments(vcpkg_make_cmake_identifier "" "${one_value_args_}" "" ${ARGN})

    if (NOT vcpkg_make_cmake_identifier_INPUT)
        message(FATAL_ERROR "vcpkg_make_cmake_identifier(): Missing required argument 'INPUT'")
    endif()
    if (NOT vcpkg_make_cmake_identifier_OUTPUT_VARIABLE)
        message(FATAL_ERROR "vcpkg_make_cmake_identifier(): Missing required argument 'OUTPUT_VARIABLE'")
    endif()

    set(valid_identifier_ "${vcpkg_make_cmake_identifier_INPUT}")
    set(invalid_characters_ "." " " ":" "-" "," "@" "!" "?" "$" "#" "%" "&" "+" "=" "/" "\\" "{" "}" "[" "]" ";" "|" "<" ">")
    foreach (invalid_character_ IN LISTS invalid_characters_)
        string(REPLACE "${invalid_character_}" "_" valid_identifier_ "${valid_identifier_}")
    endforeach()
    set(${vcpkg_make_cmake_identifier_OUTPUT_VARIABLE} "${valid_identifier_}" PARENT_SCOPE)

endfunction()
