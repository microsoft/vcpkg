set(FIND_PACKAGE_ARGS "" CACHE STRING "Arguments to the find_package command")
if(NOT FIND_PACKAGE_ARGS)
    message(FATAL_ERROR "Validation failed: The FIND_PACKAGE_ARGS option is mandatory.")
endif()

set(LABEL "${FIND_PACKAGE_ARGS}" CACHE STRING "The label to be displayed to the user")
message(STATUS "Validating ${LABEL}, CMake ${CMAKE_VERSION}")

# This project initially runs with no policies set until the tested call to
# `find_package` returns. The prolog may modify the initial state if desired.
cmake_minimum_required(VERSION 2.4)
foreach(item IN LISTS PROLOG)
    cmake_language(CALL ${item})
endforeach()

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

# Check (expected) targets and libraries
set(assume_transitive_usage_requirements "")
foreach(item IN LISTS LIBRARIES)
    if(TARGET "${item}")
        message(STATUS "Target: ${item}")
        list(APPEND assume_transitive_usage_requirements ${item})
    elseif(DEFINED "${item}")
        message(STATUS "${item}: ${${item}}")
    elseif(NOT DEFINED "${item}")
        message(FATAL_ERROR "Validation failed: ${item} is neither a target nor a variable.")
    endif()
endforeach()

# Check include dirs
set(INCLUDE_DIRS "")
if(NOT ";${FIND_PACKAGE_ARGS};" MATCHES ";CONFIG;")
    if(DEFINED ${package_upper}_INCLUDE_DIRS)
        set(include_dirs "${package_upper}_INCLUDE_DIRS")
    elseif(DEFINED ${package}_INCLUDE_DIRS)
        set(include_dirs "${package}_INCLUDE_DIRS")
    elseif(DEFINED ${package_upper}_INCLUDE_DIR)
        set(include_dirs "${package_upper}_INCLUDE_DIR")
    elseif(DEFINED ${package}_INCLUDE_DIR)
        set(include_dirs "${package}_INCLUDE_DIR")
    elseif(NOT assume_transitive_usage_requirements)
        message(FATAL_ERROR "Validation failed: <Pkg>_INCLUDE_DIR[S] is not set")
    endif()
    if(include_dirs)
        set(INCLUDE_DIRS "${${include_dirs}}")
        message(STATUS "${include_dirs}: ${INCLUDE_DIRS}")
    endif()
endif()

# Check libraries
if(NOT LIBRARIES)
    # Guess libraries variable
    if(DEFINED ${package_upper}_LIBRARIES)
        set(LIBRARIES "${package_upper}_LIBRARIES")
    elseif(DEFINED ${package}_LIBRARIES)
        set(LIBRARIES "${package}_LIBRARIES")
    elseif(NOT assume_transitive_usage_requirements)
        message(FATAL_ERROR "Validation failed: <Pkg>_LIBRARIES is not set")
    endif()
endif()

set(lib_vars_expanded "")
set(lib_vars "")
# Resolve libraries variables, but keep variable name for in-order messages.
foreach(input IN LISTS LIBRARIES)
    list(APPEND lib_vars_expanded "${input}")
    if(DEFINED "${input}")
        list(APPEND lib_vars "${input}")
        set(value "${${input}}")
        if(CMAKE_BUILD_TYPE STREQUAL "Release")
            string(REPLACE "debug;" "ignore:" value "${value}")
        elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
            string(REPLACE "optimized;" "ignore:" value "${value}")
        endif()
        list(APPEND lib_vars_expanded "${value}")
    elseif(NOT TARGET "${input}")
        message(FATAL_ERROR "Validation failed: ${input} is not a variable or target")
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
            while(NOT index LESS 0)
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

# Resolve target dependencies, but keep target name for in-order messages.
string(TOUPPER "${CMAKE_BUILD_TYPE}" config)
set(lib_targets_expanded "")
while(lib_vars_expanded)
    list(GET lib_vars_expanded 0 item)
    list(REMOVE_AT lib_vars_expanded 0)
    list(APPEND lib_targets_expanded "${item}")
    macro(check_var name)
        if(TARGET "${${name}}")
            list(APPEND lib_vars_expanded "${${name}}")
        elseif(NOT "${${name}}" MATCHES "-NOTFOUND")
            list(APPEND lib_targets_expanded "${${name}}")
        endif()
    endmacro()
    if(TARGET "${item}")
        get_target_property(mapped_config "${item}" "MAP_IMPORTED_CONFIG_${config}")
        if(mapped_config)
            string(TOUPPER "${mapped_config}" mapped_config)
        else()
            set(mapped_config "NOTFOUND")
        endif()
        set(properties
            "INTERFACE_LINK_LIBRARIES"
        )
        get_target_property(type "${item}" "TYPE")
        if(NOT type STREQUAL "INTERFACE_LIBRARY" OR NOT CMAKE_VERSION VERSION_LESS 3.19)
            list(APPEND properties
                "IMPORTED_LINK_INTERFACE_LIBRARIES"
                "IMPORTED_LINK_INTERFACE_LIBRARIES_${config}"
                "IMPORTED_LINK_INTERFACE_LIBRARIES_${mapped_config}"
            )
        endif()
        if(NOT type STREQUAL "INTERFACE_LIBRARY")
            list(APPEND properties
                "IMPORTED_IMPLIB"
                "IMPORTED_IMPLIB_${config}"
                "IMPORTED_IMPLIB_${mapped_config}"
                "IMPORTED_LOCATION"
                "IMPORTED_LOCATION_${config}"
                "IMPORTED_LOCATION_${mapped_config}"
                "LINK_INTERFACE_LIBRARIES"
                "LINK_INTERFACE_LIBRARIES_${config}"
            )
        endif()
        foreach(property IN LISTS properties)
            get_and_fixup_target_property(libs "${item}" "${property}")
            foreach(lib IN LISTS libs)
                check_var(lib)
            endforeach()
        endforeach()
    endif()
endwhile()

# Validate library file paths.
list(REMOVE_DUPLICATES lib_targets_expanded)
foreach(item IN LISTS lib_targets_expanded)
    if(item IN_LIST lib_vars)
        message(STATUS "Validating \${${item}}")
        continue()
    elseif(TARGET "${item}")
        message(STATUS "Validating target ${item}")
        continue()
    endif()
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
if(assume_transitive_usage_requirements)
    message(STATUS "Assuming that include dirs are supplied by target ${assume_transitive_usage_requirements}")
else()
    target_include_directories(main PRIVATE ${INCLUDE_DIRS})
endif()
foreach(item IN LISTS LIBRARIES)
    if(TARGET ${item})
        target_link_libraries(main PRIVATE ${item})
    else()
        set(libs "${${item}}")
        target_link_libraries(main PRIVATE ${libs})
    endif()
endforeach()
