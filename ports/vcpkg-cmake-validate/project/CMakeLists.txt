set(FIND_PACKAGE_ARGS "" CACHE STRING "Arguments to the find_package command")
if(NOT FIND_PACKAGE_ARGS)
    message(FATAL_ERROR "Validation failed: The FIND_PACKAGE_ARGS option is mandatory.")
endif()

set(LABEL "${FIND_PACKAGE_ARGS}" CACHE STRING "The label to be displayed to the user")
set(PROLOGUE "" CACHE STRING "CMake code to be executed before the project() command")
set(LIBARIES_VARIABLES "" CACHE STRING "List of libraries variables to be checked and used")
set(TARGETS "" CACHE STRING "List of targets to be checked and used")

message(STATUS "Validating ${LABEL}, CMake ${CMAKE_VERSION}")

# This project initially runs with no policies set until the tested call to
# `find_package` returns. The prolog may modify the initial state if desired.
cmake_minimum_required(VERSION 2.4)
set(prolog "")
foreach(item IN LISTS PROLOGUE)
    string(APPEND prolog "${item}\n\n")
endforeach()
if(prolog)
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/prolog.cmake" "${prolog}")
    include("${CMAKE_CURRENT_BINARY_DIR}/prolog.cmake")
endif()

project(cmake-user LANGUAGES CXX)

set(staging_path
    "${CURRENT_PACKAGES_DIR}"
    "${CURRENT_PACKAGES_DIR}/debug"
)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(REVERSE staging_path)
endif()
list(INSERT CMAKE_PREFIX_PATH 0 ${staging_path})

list(GET FIND_PACKAGE_ARGS 0 package)
string(TOUPPER "${package}" package_upper)
string(TOLOWER "${package}" package_lower)

# Find the package, verbosely
set(CMAKE_FIND_DEBUG_MODE ON)
set(staged_wrapper "${CURRENT_PACKAGES_DIR}/share/${package_lower}/vcpkg-cmake-wrapper.cmake")
if(EXISTS "${staged_wrapper}")
    message(STATUS "Using ${package} wrapper: ${staged_wrapper}")
    set(ARGS "${FIND_PACKAGE_ARGS}")
    include("${staged_wrapper}")
else()
    message(STATUS "Using using plain find_package(${package})")
    find_package(${FIND_PACKAGE_ARGS})
endif()
unset(CMAKE_FIND_DEBUG_MODE)

# find_package completed. Enable latest policies.
cmake_policy(VERSION "${CMAKE_VERSION}")

# <Pkg>_FOUND?
if(DEFINED ${package_upper}_FOUND)
    set(found_var "${package_upper}_FOUND")
elseif(DEFINED ${package}_FOUND)
    set(found_var "${package}_FOUND")
else()
    message(FATAL_ERROR "Validation failed: <Pkg>_FOUND is not defined")
endif()
if(NOT "${${found_var}}")
    message(FATAL_ERROR "Validation failed: ${found_var} is not true")
endif()
message(STATUS "${found_var}: ${${found_var}}")

# Search include dirs variable if needed
set(include_dirs "")
if(LIBRARIES_VARIABLES AND NOT TARGETS)
    if(DEFINED ${package_upper}_INCLUDE_DIRS)
        set(include_dirs_var "${package_upper}_INCLUDE_DIRS")
    elseif(DEFINED ${package}_INCLUDE_DIRS)
        set(include_dirs_var "${package}_INCLUDE_DIRS")
    elseif(DEFINED ${package_upper}_INCLUDE_DIR)
        set(include_dirs_var "${package_upper}_INCLUDE_DIR")
    elseif(DEFINED ${package}_INCLUDE_DIR)
        set(include_dirs_var "${package}_INCLUDE_DIR")
    else()
        message(FATAL_ERROR "Validation failed: <Pkg>_INCLUDE_DIR[S] is not set")
    endif()
    set(include_dirs "${${include_dirs_var}}")
    message(STATUS "${include_dirs_var}: ${include_dirs}")
endif()

# Check expected targets
foreach(target IN LISTS TARGETS)
    if(NOT TARGET "${target}")
        message(FATAL_ERROR "Validation failed: Target ${target} is missing.")
    endif()
endforeach()

# Check expected libraries variables
foreach(variable IN LISTS LIBRARIES_VARIABLES)
    if(NOT DEFINED "${variable}")
        message(FATAL_ERROR "Validation failed: Variable ${variable} is not defined.")
    endif()
endforeach()


# During this test, _IMPORT_PREFIX resolves to the package staging dir.
# But dependencies are in the target install dir.
function(get_and_fixup_target_property var target property)
    get_target_property(libs "${target}" "${property}")
    if(libs)
        set(checked "")
        foreach(input IN LISTS libs)
            # Try to handle generator expressions by looping
            set(processed "")
            string(FIND "${input}" "${CURRENT_PACKAGES_DIR}" index)
            while(NOT index LESS "0")
                string(SUBSTRING "${input}" 0 ${index} prefix)
                string(APPEND processed "${prefix}")
                string(SUBSTRING "${input}" ${index} -1 input)
                string(REGEX MATCH "^(.[^>]*)(.*)" match "${input}")
                set(input "${CMAKE_MATCH_2}")
                set(filepath "${CMAKE_MATCH_1}")
                if(NOT EXISTS "${filepath}")
                    string(REPLACE "${CURRENT_PACKAGES_DIR}" "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" installed "${filepath}")
                    if(EXISTS "${installed}")
                        set(filepath "${installed}")
                    endif()
                endif()
                string(APPEND processed "${filepath}")
                string(FIND "${input}" "${CURRENT_PACKAGES_DIR}" index)
            endwhile()
            string(APPEND processed "${input}")
            list(APPEND checked "${processed}")
        endforeach()
        set_target_properties("${target}" PROPERTIES "${property}" "${checked}")
        set(libs "${checked}")
    endif()
    set("${var}" "${libs}" PARENT_SCOPE)
endfunction()

# Get the direct properties of the target which affect linking for the given config.
function(get_target_libs out_list target config)
    get_target_property(mapped_config "${target}" "MAP_IMPORTED_CONFIG_${config}")
    if(mapped_config)
        string(TOUPPER "${mapped_config}" mapped_config)
    else()
        set(mapped_config "NOTFOUND")
    endif()
    
    get_target_property(type "${target}" "TYPE")
    set(list_properties "INTERFACE_LINK_LIBRARIES")
    set(filepath_properties "")
    if(NOT type STREQUAL "INTERFACE_LIBRARY" OR NOT CMAKE_VERSION VERSION_LESS "3.19")
        list(APPEND list_properties
            "IMPORTED_LINK_INTERFACE_LIBRARIES"
            "IMPORTED_LINK_INTERFACE_LIBRARIES_${config}"
            "IMPORTED_LINK_INTERFACE_LIBRARIES_${mapped_config}"
            "LINK_INTERFACE_LIBRARIES"
            "LINK_INTERFACE_LIBRARIES_${config}"
        )
        list(APPEND filepath_properties
            "IMPORTED_IMPLIB"
            "IMPORTED_IMPLIB_${config}"
            "IMPORTED_IMPLIB_${mapped_config}"
            "IMPORTED_LOCATION"
            "IMPORTED_LOCATION_${config}"
            "IMPORTED_LOCATION_${mapped_config}"
        )
    endif()

    message(STATUS "Target ${target}:")
    set(collected_libs "")
    foreach(property IN LISTS filepath_properties)
        get_and_fixup_target_property(filepath "${target}" "${property}")
        if(filepath)
            message(STATUS " * ${property}: ${filepath}")
            list(APPEND collected_libs "${filepath}")
        endif()
    endforeach()
    foreach(property IN LISTS list_properties)
        get_and_fixup_target_property(libs "${target}" "${property}")
        if(libs)
            message(STATUS " * ${property}: ${libs}")
            append_applicable_libs(collected_libs libs "${config}")
        endif()
    endforeach()
    set("${out_list}" "${collected_libs}" PARENT_SCOPE)
endfunction()

# Copy libs that are relevant for the given config
function(append_applicable_libs out_list list_var config)
    if(config STREQUAL "DEBUG")
        string(REGEX REPLACE ";optimized;[^;]*" ";" libs "generic;${${list_var}}")
    else()
        string(REGEX REPLACE ";debug;[^;]*" ";" libs "generic;${${list_var}}")
    endif()
    set(applicable_libs "${${out_list}}")
    foreach(lib IN LISTS libs)
        if(NOT lib MATCHES "^optimized\$|^debug\$|^generic\$")
            list(APPEND applicable_libs "${lib}")
        endif()
    endforeach()
    set("${out_list}" "${applicable_libs}" PARENT_SCOPE)
endfunction()

string(TOUPPER "${CMAKE_BUILD_TYPE}" config)
set(libs_backlog "${TARGETS}")
foreach(variable IN LISTS LIBRARIES_VARIABLES)
    set(link_libraries "${${variable}}")
    if(NOT "${link_libraries}" STREQUAL "")
        message(STATUS "${variable}: ${link_libraries}")
        append_applicable_libs(libs_backlog link_libraries "${config}")
    endif()
endforeach()

set(visited_targets "")
set(libs_expanded "")
while(libs_backlog)
    list(GET libs_backlog 0 item)
    list(REMOVE_AT libs_backlog 0)
    if(TARGET "${item}")
        if(NOT "${item}" IN_LIST visited_targets)
            list(APPEND visited_targets "${item}")
            get_target_libs(target_libs "${item}" "${config}")
            append_applicable_libs(libs_backlog target_libs "${config}")
        endif()
    else()
        list(APPEND libs_expanded "${item}")
    endif()
endwhile()


# Validate library file paths.
message(STATUS "Validating collected link items")
list(REMOVE_ITEM libs_expanded "")
list(REMOVE_DUPLICATES libs_expanded)
foreach(item IN LISTS libs_expanded)
    set(prefix "${CURRENT_PACKAGES_DIR}/")
    string(FIND "${item}" "${prefix}" prefix_found)
    if(prefix_found LESS 0)
        set(prefix "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/")
        string(FIND "${item}" "${prefix}" prefix_found)
    endif()
    if(NOT prefix_found EQUAL 0)
        message(STATUS "  other: ${item}")
        continue()
    endif()
    string(FIND "${item}" "${prefix}lib/" release_found)
    string(FIND "${item}" "${prefix}debug/lib/" debug_found)
    if(CMAKE_BUILD_TYPE STREQUAL "Release" AND debug_found EQUAL 0)
        message(SEND_ERROR "Validation failed: Debug lib in release build: ${item}")
    elseif(CMAKE_BUILD_TYPE STREQUAL "Debug" AND release_found EQUAL 0)
        message(SEND_ERROR "Validation failed: Release lib in debug build: ${item}")
    else()
        message(STATUS "  valid: ${item}")
    endif()
endforeach()

set(source 
"// Generated from vcpkg_cmake_validate

$<$<BOOL:${HEADERS}>:#include <$<JOIN:${HEADERS},$<ANGLE-R>\n  #include <>$<ANGLE-R>>

typedef int (*f_type)(void);

int main(void) {
  f_type func = 0;
$<$<BOOL:${FUNCTIONS}>:  func = (f_type)&$<JOIN:${FUNCTIONS},;\n  func = (f_type)&>;>
  return func ? func() : 0;
}
")
set(source_file "${CMAKE_CURRENT_BINARY_DIR}/src.cxx")
file(GENERATE OUTPUT "${source_file}" CONTENT "${source}")

add_executable(main "${source_file}")
if(TARGETS)
    target_link_libraries(main PRIVATE ${TARGETS})
else()
    target_include_directories(main PRIVATE ${include_dirs})
    foreach(var IN LISTS LIBRARIES_VARIABLES)
        set(libs "${${var}}")
        target_link_libraries(main PRIVATE ${libs})
    endforeach()
endif()
