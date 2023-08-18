include_guard(GLOBAL)

### Mapping variables
macro(z_vcpkg_make_set_common_vars)
    set(path_suffix_RELEASE "")
    set(path_suffix_DEBUG "/debug")
    set(suffix_RELEASE "rel")
    set(suffix_DEBUG "dbg")
    foreach(z_vcpkg_make_config IN ITEMS RELEASE DEBUG)
        set("workdir_${z_vcpkg_make_config}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${z_vcpkg_make_config}}")
    endforeach()
    unset(z_vcpkg_make_config)
endmacro()

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

function(z_vcpkg_convert_to_msys_path outvar invar)
    if(CMAKE_HOST_WIN32)
        string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" current_installed_dir_msys "${invar}")
    endif()
    set("${outvar}" "${current_installed_dir_msys}" PARENT_SCOPE)
endfunction()
function(z_vcpkg_escape_spaces_in_path outvar invar)
    string(REPLACE " " "\\ " current_installed_dir_escaped "${invar}")
    set("${outvar}" "${current_installed_dir_escaped}" PARENT_SCOPE)
endfunction()

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

macro(z_vcpkg_required_args)
    set(not_args "")
    foreach(${CMAKE_CURRENT_FUNCTION}_index RANGE 0 "${ARGC}")
        if(NOT ${ARGV${${CMAKE_CURRENT_FUNCTION}_index}})
            list(APPEND not_args "${ARGV${${CMAKE_CURRENT_FUNCTION}_index}}")
        endif()
    endforeach()
    list(LENGTH not_args not_args_length)
    if(not_args_length GREATER 0)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was not passed required arguments:'${not_args}'!")
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

function(vcpkg_prepare_pkgconfig config)
    set(subdir "")
    if(config MATCHES "(DEBUG|debug)")
        set(subdir "/debug")
    endif()

    foreach(envvar IN ITEMS PKG_CONFIG PKG_CONFIG_PATH)
        if(DEFINED ENV{${envvar}})
            z_vcpkg_set_global_property("make-pkg-config-backup-${envvar}" "$ENV{${envvar}}")
        else()
            z_vcpkg_set_global_property("make-pkg-config-backup-${envvar}")
        endif()
    endforeach()

    vcpkg_find_acquire_program(PKGCONFIG)
    get_filename_component(pkgconfig_path "${PKGCONFIG}" DIRECTORY)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")

    vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} 
                            "${CURRENT_INSTALLED_DIR}/share/pkgconfig/"
                            "${CURRENT_INSTALLED_DIR}${subdir}/lib/pkgconfig/"
                            "${CURRENT_PACKAGES_DIR}/share/pkgconfig/"
                            "${CURRENT_PACKAGES_DIR}${subdir}/lib/pkgconfig/"
                        )
endfunction()

function(vcpkg_restore_pkgconfig)
    foreach(envvar IN ITEMS PKG_CONFIG PKG_CONFIG_PATH)
        z_vcpkg_get_global_property(has_backup "make-pkg-config-backup-${envvar}" SET)
        if(has_backup)
            z_vcpkg_get_global_property(backup "make-pkg-config-backup-${envvar}")
            set("ENV{${envvar}}" "${backup}")
            z_vcpkg_set_global_property("make-pkg-config-backup-${envvar}")
        else()
            unset("ENV{${envvar}}")
        endif()
    endforeach()
endfunction()

###
function(vcpkg_insert_into_path)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "" 
        "PATH_OUT;IS_INSERTED"
        "INSERT;BEFORE"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)
    z_vcpkg_required_args(INSERT)
    #z_vcpkg_conflicting_args(arg_BEFORE arg_AFTER)
    cmake_path(CONVERT "$ENV{PATH}" TO_CMAKE_PATH_LIST path_list NORMALIZE)

    if(DEFINED arg_BEFORE)
        string(TOLOWER "${arg_BEFORE}" search_lower)
        cmake_path(CONVERT "${search_lower}" TO_CMAKE_PATH_LIST search_lower NORMALIZE)
    endif()

    set(index 0)
    set("${arg_IS_INSERTED}" FALSE PARENT_SCOPE)
    foreach(item IN LISTS path_list)
        string(TOLOWER "${item}" item_lower)
        if(item_lower IN_LIST search_lower)
            set("${arg_IS_INSERTED}" TRUE PARENT_SCOPE)
            break()
        endif()
        math(EXPR index "${index} + 1")
    endforeach()

    vcpkg_list(INSERT path_list "${index}" ${arg_INSERT})
    cmake_path(CONVERT "${path_list}" TO_NATIVE_PATH_LIST native_path_list)
    set(ENV{PATH} "${native_path_list}")
    if(DEFINED arg_PATH_OUT AND NOT arg_PATH_OUT STREQUAL "")
        set("${arg_PATH_OUT}" "${path_list}" PARENT_SCOPE)
    endif()
endfunction()

function(vcpkg_insert_msys_into_path msys_out)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "" 
        "PATH_OUT"
        "PACKAGES"
    )
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${arg_ADDITIONAL_PACKAGES})

    cmake_path(CONVERT "$ENV{SystemRoot}" TO_CMAKE_PATH_LIST system_root NORMALIZE)
    cmake_path(CONVERT "$ENV{LOCALAPPDATA}" TO_CMAKE_PATH_LIST local_app_data NORMALIZE)
    file(REAL_PATH "${system_root}" system_root)

    vcpkg_list(SET find_system_dirs 
        "${system_root}/system32"
        "${system_root}/system32/"
        "${local_app_data}/Microsoft/WindowsApps"
        "${local_app_data}/Microsoft/WindowsApps/"
    )

    vcpkg_insert_into_path(
        PATH_OUT "${arg_PATH_OUT}"
        IS_INSERTED inserted
        INSERT "${MSYS_ROOT}/usr/bin"
        BEFORE ${find_system_dirs})

    if(inserted)
        message(WARNING "Unable to find system dir in the PATH variable! Appending required msys paths!")
    endif()

    if(DEFINED arg_PATH_OUT)
        set("${arg_PATH_OUT}" "${${arg_PATH_OUT}}" PARENT_SCOPE)
    endif()

    set("${msys_out}" "${MSYS_ROOT}" PARENT_SCOPE)
endfunction()
