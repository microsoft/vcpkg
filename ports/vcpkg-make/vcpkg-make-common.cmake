include_guard(GLOBAL)


macro(z_vcpkg_append_to_configure_environment inoutstring var defaultval)
    # Allows to overwrite settings in custom triplets via the environment on windows
    if(CMAKE_HOST_WIN32 AND DEFINED ENV{${var}})
        string(APPEND "${inoutstring}" " ${var}='$ENV{${var}}'")
    else()
        string(APPEND "${inoutstring}" " ${var}='${defaultval}'")
    endif()
endmacro()

### Mapping variables
macro(z_vcpkg_make_set_common_vars)
    set(path_suffix_RELEASE "")
    set(path_suffix_DEBUG "/debug")
    set(suffix_RELEASE "rel")
    set(suffix_DEBUG "dbg")
    foreach(config IN ITEMS RELEASE DEBUG)
        set("workdir_${config}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${config}}")
    endforeach()
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

function(z_vcpkg_make_prepare_compile_flags var_suffix)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "NO_CPP;NO_FLAG_ESCAPING;USES_WRAPPERS" 
        "COMPILER_FRONTEND;CONFIG"
        "LANGUAGES"
    )
    # TODO: Deal with LANGUAGES
    # TODO: Check params

    set(var_suffix "${arg_CONFIG}")

    # separate_aruments is needed to remove outer quotes from detected cmake variables.
    # (e.g. Android NDK has "--sysroot=...")
    separate_arguments(CFLAGS NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_C_FLAGS_${var_suffix}}")
    separate_arguments(CXXFLAGS NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${var_suffix}}")
    separate_arguments(LDFLAGS NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${var_suffix}}")
    separate_arguments(ARFLAGS NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${var_suffix}}")
    foreach(var IN ITEMS CFLAGS CXXFLAGS LDFLAGS ARFLAGS)
        vcpkg_list(APPEND flags ${${var}})
    endforeach()

    set(abiflags "")
    set(pattern "")
    foreach(arg IN LISTS CFLAGS)
        if(NOT pattern STREQUAL "")
            vcpkg_list(APPEND pattern "${arg}")
        elseif(arg MATCHES "^--(sysroot|target)=.")
            vcpkg_list(SET pattern "${arg}")
        elseif(arg MATCHES "^-(isysroot|m32|m64|m?[Aa][Rr][Cc][Hh]|target)\$")
            vcpkg_list(SET pattern "${arg}")
            continue()
        else()
            continue()
        endif()
        vcpkg_list(APPEND abiflags ${pattern})
        list(REMOVE_ITEM CFLAGS "${pattern}")
        list(REMOVE_ITEM CXXFLAGS "${pattern}")
        list(REMOVE_ITEM LDFLAGS "${pattern}")
        set(pattern "")
    endforeach()

    # Filter common CPPFLAGS out of CFLAGS and CXXFLAGS
    if(NOT arg_NO_CPP)
        set(CPPFLAGS "")
        set(pattern "")
        foreach(arg IN LISTS CXXFLAGS)
            if(NOT pattern STREQUAL "")
                vcpkg_list(APPEND pattern "${arg}")
            elseif(arg MATCHES "^-(D|isystem).")
                vcpkg_list(SET pattern "${arg}")
            elseif(arg MATCHES "^-(D|isystem)\$")
                vcpkg_list(SET pattern "${arg}")
                continue()
            else()
                continue()
            endif()
            string(FIND "${CFLAGS}" "${pattern} " index)
            if(NOT index STREQUAL "-1")
                vcpkg_list(APPEND CPPFLAGS ${pattern})
                list(REMOVE_ITEM CFLAGS "${pattern}")
                list(REMOVE_ITEM CXXFLAGS "${pattern}")
                list(REMOVE_ITEM LDFLAGS "${pattern}")
            endif()
        endforeach()
        set(pattern "")
        foreach(arg IN LISTS CFLAGS)
            if(NOT pattern STREQUAL "")
                vcpkg_list(APPEND pattern "${arg}")
            elseif(arg MATCHES "^-(D|isystem)\$")
                vcpkg_list(SET pattern "${arg}")
                continue()
            elseif(arg MATCHES "^-(D|isystem).")
                vcpkg_list(SET pattern "${arg}")
            else()
                continue()
            endif()
            string(FIND "${CXXFLAGS}" "${pattern} " index)
            if(NOT index STREQUAL "-1")
                vcpkg_list(APPEND CPPFLAGS ${pattern})
                list(REMOVE_ITEM CFLAGS "${pattern}")
                list(REMOVE_ITEM CXXFLAGS "${pattern}")
                list(REMOVE_ITEM LDFLAGS "${pattern}")
            endif()
            vcpkg_list(SET pattern)
        endforeach()
    endif()

    # libtool tries to filter CFLAGS passed to the link stage via a whitelist.
    # This approach is flawed since it fails to pass flags unknown to libtool
    # but required for linking to the link stage (e.g. -fsanitize=<x>).
    # libtool has an -R option so we need to guard against -RTC by using -Xcompiler.
    # While configuring there might be a lot of unknown compiler option warnings
    # due to that; just ignore them.
    set(compiler_flag_escape "")
    if(arg_COMPILER_FRONTEND STREQUAL "MSVC" AND NOT arg_NO_FLAG_ESCAPING)
        set(compiler_flag_escape "-Xcompiler") # TODO: Check why this had a trailing space? We are using lists so it shouldn't be necessary here
    endif()
    if(compiler_flag_escape)
        list(TRANSFORM CFLAGS PREPEND "${compiler_flag_escape}")
        list(TRANSFORM CXXFLAGS PREPEND "${compiler_flag_escape}")
    endif()

    set(library_path_flag "${VCPKG_DETECTED_CMAKE_LIBRARY_PATH_FLAG}")

    set(linker_flag_escape "")
    if(arg_COMPILER_FRONTEND STREQUAL "MSVC" AND NOT arg_NO_FLAG_ESCAPING)
        # Removed by libtool
        set(linker_flag_escape "-Xlinker ")
        if(arg_USES_WRAPPERS)
            # 1st and 3rd are removed by libtool, 2nd by wrapper
            set(linker_flag_escape "-Xlinker -Xlinker -Xlinker ")
        endif()
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            string(STRIP "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${var_suffix}}" LINK_ENV)
        else()
            string(STRIP "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${var_suffix}}" LINK_ENV)
        endif()
    endif()
    if(linker_flag_escape)
        string(STRIP "${linker_flag_escape}" linker_flag_escape_stripped)
        string(REPLACE " " ";" linker_flag_escape_stripped "${linker_flag_escape_stripped}")
        list(TRANSFORM LDFLAGS PREPEND "${linker_flag_escape_stripped}")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${var_suffix}}/lib/manual-link")
        vcpkg_list(PREPEND LDFLAGS "${linker_flag_escape}${library_path_flag}${current_installed_dir_escaped}${path_suffix_${var_suffix}}/lib/manual-link")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${var_suffix}}/lib")
        vcpkg_list(PREPEND LDFLAGS "${linker_flag_escape}${library_path_flag}${current_installed_dir_escaped}${path_suffix_${var_suffix}}/lib")
    endif()

    if(ARFLAGS)
        # ARFLAGS need to know the command for creating an archive (Maybe needs user customization?)
        # or extract it from CMake via CMAKE_${lang}_ARCHIVE_CREATE ?
        # or from CMAKE_${lang}_${rule} with rule being one of CREATE_SHARED_MODULE CREATE_SHARED_LIBRARY LINK_EXECUTABLE
        vcpkg_list(PREPEND ARFLAGS "cr")
    endif()

    foreach(var IN ITEMS ABIFLAGS CPPFLAGS CFLAGS CXXFLAGS LDFLAGS ARFLAGS)
        list(JOIN ${var} " " string)
        set(${var}_${var_suffix} "${string}" PARENT_SCOPE)
    endforeach()

    # TODO Forward required vars;
endfunction()



function(z_vcpkg_make_prepare_program_flags)
    # Remove full filepaths due to spaces and prepend filepaths to PATH (cross-compiling tools are unlikely on path by default)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(progs   VCPKG_DETECTED_CMAKE_C_COMPILER VCPKG_DETECTED_CMAKE_CXX_COMPILER VCPKG_DETECTED_CMAKE_AR
                    VCPKG_DETECTED_CMAKE_LINKER VCPKG_DETECTED_CMAKE_RANLIB VCPKG_DETECTED_CMAKE_OBJDUMP
                    VCPKG_DETECTED_CMAKE_STRIP VCPKG_DETECTED_CMAKE_NM VCPKG_DETECTED_CMAKE_DLLTOOL VCPKG_DETECTED_CMAKE_RC_COMPILER)
        foreach(prog IN LISTS progs)
            set(filepath "${${prog}}")
            if(filepath MATCHES " ")
                cmake_path(GET filepath FILENAME ${prog})
                find_program(z_vcm_prog_found NAMES "${${prog}}" PATHS ENV PATH NO_DEFAULT_PATH NO_CACHE)
                if(NOT z_vcm_prog_found STREQUAL filepath)
                    cmake_path(GET filepath PARENT_PATH dir)
                    vcpkg_add_to_path(PREPEND "${dir}")
                endif()
            endif()
        endforeach()
        if (arg_USE_WRAPPERS)
            z_vcpkg_append_to_configure_environment(configure_env CPP "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
            z_vcpkg_append_to_configure_environment(configure_env CC "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env CXX "compile ${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")        
            if(NOT arg_BUILD_TRIPLET MATCHES "--host") # TODO: Check if this generates problems with the new triplet approach
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            else()
                # Silly trick to make configure accept CC_FOR_BUILD but in reallity CC_FOR_BUILD is deactivated. 
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            endif()

            z_vcpkg_append_to_configure_environment(configure_env RC "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env WINDRES "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib ${VCPKG_DETECTED_CMAKE_AR}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib lib.exe -verbose")
            endif()
        else()
            z_vcpkg_append_to_configure_environment(configure_env CPP "${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
            z_vcpkg_append_to_configure_environment(configure_env CC "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env CXX "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            if(NOT arg_BUILD_TRIPLET MATCHES "--host")
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            endif()
            z_vcpkg_append_to_configure_environment(configure_env RC "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env WINDRES "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                z_vcpkg_append_to_configure_environment(configure_env AR "${VCPKG_DETECTED_CMAKE_AR}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env AR "lib.exe -verbose")
            endif()
        endif()
        z_vcpkg_append_to_configure_environment(configure_env LD "${VCPKG_DETECTED_CMAKE_LINKER} -verbose")
        if(VCPKG_DETECTED_CMAKE_RANLIB)
            z_vcpkg_append_to_configure_environment(configure_env RANLIB "${VCPKG_DETECTED_CMAKE_RANLIB}") # Trick to ignore the RANLIB call
        else()
            z_vcpkg_append_to_configure_environment(configure_env RANLIB ":")
        endif()
        if(VCPKG_DETECTED_CMAKE_OBJDUMP) #Objdump is required to make shared libraries. Otherwise define lt_cv_deplibs_check_method=pass_all
            z_vcpkg_append_to_configure_environment(configure_env OBJDUMP "${VCPKG_DETECTED_CMAKE_OBJDUMP}") # Trick to ignore the RANLIB call
        endif()
        if(VCPKG_DETECTED_CMAKE_STRIP) # If required set the ENV variable STRIP in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env STRIP "${VCPKG_DETECTED_CMAKE_STRIP}") 
        else()
            z_vcpkg_append_to_configure_environment(configure_env STRIP ":")
            list(APPEND arg_OPTIONS ac_cv_prog_ac_ct_STRIP=:)
        endif()
        if(VCPKG_DETECTED_CMAKE_NM) # If required set the ENV variable NM in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env NM "${VCPKG_DETECTED_CMAKE_NM}") 
        else()
            # Would be better to have a true nm here! Some symbols (mainly exported variables) get not properly imported with dumpbin as nm 
            # and require __declspec(dllimport) for some reason (same problem CMake has with WINDOWS_EXPORT_ALL_SYMBOLS)
            z_vcpkg_append_to_configure_environment(configure_env NM "dumpbin.exe -symbols -headers")
        endif()
        if(VCPKG_DETECTED_CMAKE_DLLTOOL) # If required set the ENV variable DLLTOOL in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env DLLTOOL "${VCPKG_DETECTED_CMAKE_DLLTOOL}") 
        else()
            z_vcpkg_append_to_configure_environment(configure_env DLLTOOL "link.exe -verbose -dll")
        endif()
        z_vcpkg_append_to_configure_environment(configure_env CCAS ":")   # If required set the ENV variable CCAS in the portfile correctly
        z_vcpkg_append_to_configure_environment(configure_env AS ":")   # If required set the ENV variable AS in the portfile correctly

        foreach(_env IN LISTS arg_CONFIGURE_ENVIRONMENT_VARIABLES)
            z_vcpkg_append_to_configure_environment(configure_env ${_env} "${${_env}}")
        endforeach()
    else()
        # OSX dosn't like CMAKE_C(XX)_COMPILER (cc) in CC/CXX and rather wants to have gcc/g++
        vcpkg_list(SET z_vcm_all_tools)
        function(z_vcpkg_make_set_env envvar cmakevar)
            set(prog "${VCPKG_DETECTED_CMAKE_${cmakevar}}")
            if(NOT DEFINED ENV{${envvar}} AND NOT prog STREQUAL "")
                vcpkg_list(APPEND z_vcm_all_tools "${prog}")
                if(ARGN)
                    string(APPEND prog " ${ARGN}")
                endif()
                set(z_vcm_all_tools "${z_vcm_all_tools}" PARENT_SCOPE)
                set(ENV{${envvar}} "${prog}")
            endif()
        endfunction()
        z_vcpkg_make_set_env(CC C_COMPILER)
        if(NOT arg_BUILD_TRIPLET MATCHES "--host")
            z_vcpkg_make_set_env(CC_FOR_BUILD C_COMPILER)
            z_vcpkg_make_set_env(CPP_FOR_BUILD C_COMPILER "-E")
            z_vcpkg_make_set_env(CXX_FOR_BUILD C_COMPILER)
        else()
            set(ENV{CC_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            set(ENV{CPP_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            set(ENV{CXX_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
        endif()
        z_vcpkg_make_set_env(CXX CXX_COMPILER)
        z_vcpkg_make_set_env(NM NM)
        z_vcpkg_make_set_env(RC RC)
        z_vcpkg_make_set_env(WINDRES RC)
        z_vcpkg_make_set_env(DLLTOOL DLLTOOL)
        z_vcpkg_make_set_env(STRIP STRIP)
        z_vcpkg_make_set_env(OBJDUMP OBJDUMP)
        z_vcpkg_make_set_env(RANLIB RANLIB)
        z_vcpkg_make_set_env(AR AR)
        z_vcpkg_make_set_env(LD LINKER)
        unset(z_vcpkg_make_set_env)

        list(FILTER z_vcm_all_tools INCLUDE REGEX " ")
        if(z_vcm_all_tools)
            list(REMOVE_DUPLICATES z_vcm_all_tools)
            list(JOIN z_vcm_all_tools "\n   " tools)
            message(STATUS "Warning: Tools with embedded space may be handled incorrectly by configure:\n   ${tools}")
        endif()
    endif()
endfunction()

function(z_vcpkg_make_prepare_flags)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "NO_CPP" 
        "LIBS_OUT"
        "LANGUAGES"
    )
    if(DEFINED arg_LANGUAGES)
        # What a nice trick to get more output from vcpkg_cmake_get_vars if required
        # But what will it return for ASM on windows? TODO: Needs actual testing
        # list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_LANGUAGES=C\;CXX\;ASM") ASM compiler will point to CL with MSVC
        list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_LANGUAGES=${arg_LANGUAGES};-DVCPKG_DEFAULT_VARS_TO_CHECK=CMAKE_LIBRARY_PATH_FLAG")
    endif()
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    #TODO: parent scope requiered vars

endfunction()

function(z_vcpkg_make_prepare_environment_common)
endfunction()

function(vcpkg_make_default_path_parameters out_var)
    # THIS IS TODO
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "" 
        "CONFIG"
        ""
    )
    # Set configure paths
    vcpkg_list(APPEND arg_OPTIONS_RELEASE "--prefix=${current_installed_dir_msys}")
    vcpkg_list(APPEND arg_OPTIONS_DEBUG "--prefix=${current_installed_dir_msys}${path_suffix_DEBUG}")
    if(NOT arg_NO_ADDITIONAL_PATHS)
        # ${prefix} has an extra backslash to prevent early expansion when calling `bash -c configure "..."`.
        vcpkg_list(APPEND arg_OPTIONS_RELEASE
                            # Important: These should all be relative to prefix!
                            "--bindir=\\\${prefix}/tools/${PORT}/bin"
                            "--sbindir=\\\${prefix}/tools/${PORT}/sbin"
                            "--libdir=\\\${prefix}/lib" # On some Linux distributions lib64 is the default
                            #"--includedir='\${prefix}'/include" # already the default!
                            "--mandir=\\\${prefix}/share/${PORT}"
                            "--docdir=\\\${prefix}/share/${PORT}"
                            "--datarootdir=\\\${prefix}/share/${PORT}")
        vcpkg_list(APPEND arg_OPTIONS_DEBUG
                            # Important: These should all be relative to prefix!
                            "--bindir=\\\${prefix}/../tools/${PORT}${path_suffix_DEBUG}/bin"
                            "--sbindir=\\\${prefix}/../tools/${PORT}${path_suffix_DEBUG}/sbin"
                            "--libdir=\\\${prefix}/lib" # On some Linux distributions lib64 is the default
                            "--includedir=\\\${prefix}/../include"
                            "--mandir=\\\${prefix}/share/${PORT}"
                            "--docdir=\\\${prefix}/share/${PORT}"
                            "--datarootdir=\\\${prefix}/share/${PORT}")
    endif()
    # Setup common options
    if(NOT arg_DISABLE_VERBOSE_FLAGS)
        list(APPEND arg_OPTIONS --disable-silent-rules --verbose)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        list(APPEND arg_OPTIONS --enable-shared --disable-static)
    else()
        list(APPEND arg_OPTIONS --disable-shared --enable-static)
    endif()
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
