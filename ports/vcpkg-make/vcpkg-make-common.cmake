include_guard(GLOBAL)

### Mapping variables


####
function(z_vcpkg_make_determine_arch out_var value)
    if(${value} MATCHES "(amd|AMD)64")
        set(${out_var} x86_64 PARENT_SCOPE)
    elseif(${value} MATCHES "(x|X)86")
        set(${out_var} i686 PARENT_SCOPE)
    elseif(${value} MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64 PARENT_SCOPE)
    elseif(${value} MATCHES "^(ARM|arm)$")
        set(${out_var} arm PARENT_SCOPE)
    elseif(${value} MATCHES "^(x86_64|i686|aarch64|arm)$" OR NOT VCPKG_TARGET_IS_WINDOWS)
        # Do nothing an assume valid architectures
        set("${out_var}" "${value}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Unsupported architecture '${value}' in '${CMAKE_CURRENT_FUNCTION}'!" )
    endif()
endfunction()

function(z_vcpkg_make_determine_host_arch out_var)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(arch $ENV{PROCESSOR_ARCHITEW6432})
    elseif(DEFINED ENV{PROCESSOR_ARCHITECTURE})
        set(arch $ENV{PROCESSOR_ARCHITECTURE})
    else()
        set(arch "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    endif()
    z_vcpkg_make_determine_arch("${out_var}" "${arch}")
    set("${out_var}" "${${out_var}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_make_determine_target_arch out_var)
    list(LENGTH VCPKG_OSX_ARCHITECTURES osx_archs_num)
    if(osx_archs_num GREATER_EQUAL 2 AND VCPKG_TARGET_IS_OSX)
        set(${out_var} "universal")
    else()
        z_vcpkg_make_determine_arch(${out_var} "${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    set("${out_var}" "${${out_var}}" PARENT_SCOPE)
endfunction()


function(z_vcpkg_make_prepare_compiler_flags)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "NO_CPP" 
        "LIBS_OUT"
        "LANGUAGES"
    )
    if(DEFINED arg_LANGUAGES)
        # What a nice trick to get more output from vcpkg_cmake_get_vars if required
        # But what will it return for ASM on windows? TODO: Needs actual testing
        # list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_LANGUAGES=C\;CXX\;ASM") ASM compiler will point to CL with MSVC
        list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_LANGUAGES=${arg_LANGUAGES}")
    endif()
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    #TODO: parent scope requiered vars

endfunction()

function(z_vcpkg_make_prepare_environment_common)
endfunction()


### General helper scripts (should maybe be moved to a seperate port)

macro(z_vcpkg_unparsed_args warning_level)
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message("${warning_level}" "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
endmacro()

macro(z_vcpkg_conflicting_args)
    set(conflicting_args_set "")
    foreach(z_vcpkg_conflicting_args_index RANGE 0 "${ARGC}")
        if(${ARGV${z_vcpkg_conflicting_args_index}})
            list(APPEND conflicting_args_set "${ARGV${z_vcpkg_conflicting_args_index}}")
        endif()
    endforeach()
    list(LENGTH conflicting_args_set conflicting_args_set_length)
    if(conflicting_args_set_length GREATER 1)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed conflicting arguments:'${conflicting_args_set}'. Only one of those arguments can be passed")
    endif()
    unset(conflicting_args_set_length)
    unset(conflicting_args_set)
    unset(z_vcpkg_conflicting_args_index)
endmacro()

function(z_vcpkg_set_global_property property value)
    if(DEFINED ARGN AND NOT ARGN MATCHES "^APPEND(_STRING)?$")
        message(FATAL_ERROR "'${CMAKE_CURRENT_FUNCTION}' called with invalid arguments '${ARGN}'")
    endif()
    set_property(GLOBAL ${ARGN} PROPERTY "z_vcpkg_global_property_${property}" ${value})
endfunction()

function(z_vcpkg_get_global_property outvar property)
    if(DEFINED ARGN AND NOT ARGN STREQUAL "SET")
        message(FATAL_ERROR "'${CMAKE_CURRENT_FUNCTION}' called with invalid arguments '${ARGN}'")
    endif()
    get_property(outprop GLOBAL PROPERTY "z_vcpkg_global_property_${property}" ${ARGN})
    set(${outvar} "${outprop}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_warn_path_with_spaces)
    vcpkg_list(SET z_vcm_paths_with_spaces)
    if(CURRENT_BUILDTREES_DIR MATCHES " ")
        vcpkg_list(APPEND z_vcm_paths_with_spaces "${CURRENT_BUILDTREES_DIR}")
    endif()
    if(CURRENT_PACKAGES_DIR MATCHES " ")
        vcpkg_list(APPEND z_vcm_paths_with_spaces "${CURRENT_PACKAGES_DIR}")
    endif()
    if(CURRENT_INSTALLED_DIR MATCHES " ")
        vcpkg_list(APPEND z_vcm_paths_with_spaces "${CURRENT_INSTALLED_DIR}")
    endif()
    if(z_vcm_paths_with_spaces)
        # Don't bother with whitespace. The tools will probably fail and I tried very hard trying to make it work (no success so far)!
        vcpkg_list(APPEND z_vcm_paths_with_spaces "Please move the path to one without whitespaces!")
        list(JOIN z_vcm_paths_with_spaces "\n   " z_vcm_paths_with_spaces)
        message(STATUS "Warning: Paths with embedded space may be handled incorrectly by configure:\n   ${z_vcm_paths_with_spaces}")
    endif()
endfunctioN()

###
function(vcpkg_insert_msys_into_path msys_out)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "" 
        "PATH_OUT"
        "PACKAGES"
    )
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${arg_ADDITIONAL_PACKAGES})
    cmake_path(CONVERT "$ENV{PATH}" TO_CMAKE_PATH_LIST path_list NORMALIZE)
    cmake_path(CONVERT "$ENV{SystemRoot}" TO_CMAKE_PATH_LIST system_root NORMALIZE)
    cmake_path(CONVERT "$ENV{LOCALAPPDATA}" TO_CMAKE_PATH_LIST local_app_data NORMALIZE)
    file(REAL_PATH "${system_root}" system_root)

    vcpkg_list(SET find_system_dirs 
        "${system_root}/system32"
        "${system_root}/System32"
        "${system_root}/system32/"
        "${system_root}/System32/"
        "${local_app_data}/Microsoft/WindowsApps"
        "${local_app_data}/Microsoft/WindowsApps/"
    )

    string(TOUPPER "${find_system_dirs}" find_system_dirs_upper)

    set(index 0)
    set(appending TRUE)
    foreach(item IN LISTS path_list)
        if(item IN_LIST find_system_dirs OR item IN_LIST find_system_dirs_upper)
            set(appending FALSE)
            break()
        endif()
        math(EXPR index "${index} + 1")
    endforeach()

    if(appending)
        message(WARNING "Unable to find system dir in the PATH variable! Appending required msys paths!")
    endif()
    vcpkg_list(INSERT path_list "${index}" "${MSYS_ROOT}/usr/bin")

    cmake_path(CONVERT "${path_list}" TO_NATIVE_PATH_LIST native_path_list)
    set(ENV{PATH} "${native_path_list}") # Should this be backed up?

    if(DEFINED arg_PATH_OUT)
        set("${arg_PATH_OUT}" "${path_list}" PARENT_SCOPE)
    endif()

    set("${msys_out}" "${MSYS_ROOT}" PARENT_SCOPE)
endfunction()
