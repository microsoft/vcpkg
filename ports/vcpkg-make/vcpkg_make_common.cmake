include_guard(GLOBAL)

### Mapping variables
macro(z_vcpkg_make_set_common_vars)
    set(path_suffix_RELEASE "")
    set(path_suffix_DEBUG "/debug")
    set(suffix_RELEASE "rel")
    set(suffix_DEBUG "dbg")
    foreach(config IN ITEMS RELEASE DEBUG)
        set("workdir_${config}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${config}}")
    endforeach()
    set(buildtypes release)
    if(NOT VCPKG_BUILD_TYPE)
        list(PREPEND buildtypes debug)
    endif()
endmacro()

###
macro(z_vcpkg_make_get_cmake_vars)
    cmake_parse_arguments(vmgcv_arg # Not just arg since macros don't define their own var scope. 
        "" "" "LANGUAGES" ${ARGN}
    )

    z_vcpkg_get_global_property(has_cmake_vars_file "make_cmake_vars_file" SET)

    if(NOT has_cmake_vars_file)
        if(vmgcv_arg_LANGUAGES)
            # Escape semicolons to prevent CMake from splitting LANGUAGES list when passing as -D option.
            string(REPLACE ";" "\;" vmgcv_arg_langs "${vmgcv_arg_LANGUAGES}")
            list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_LANGUAGES=${vmgcv_arg_langs}")
            unset(langs)
        endif()

        list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_DEFAULT_VARS_TO_CHECK=CMAKE_LIBRARY_PATH_FLAG")
        vcpkg_cmake_get_vars(cmake_vars_file)
        z_vcpkg_set_global_property(make_cmake_vars_file "${cmake_vars_file}")
    else()
        z_vcpkg_get_global_property(cmake_vars_file "make_cmake_vars_file")
    endif()

    include("${cmake_vars_file}")
endmacro()

function(z_vcpkg_make_normalize_arch out_var value)
    if(${value} MATCHES "^(amd|AMD|x)64$")
        set(${out_var} x86_64 PARENT_SCOPE)
    elseif(${value} MATCHES "^(x|X)86$")
        set(${out_var} i686 PARENT_SCOPE)
    elseif(${value} MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64 PARENT_SCOPE)
    elseif(${value} MATCHES "^(ARM|arm)$")
        set(${out_var} arm PARENT_SCOPE)
    elseif(${value} MATCHES "^(x86_64|i686|aarch64)$" OR NOT VCPKG_TARGET_IS_WINDOWS)
        # Do nothing and assume valid architecture
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
        z_vcpkg_make_get_cmake_vars(#[[ LANGUAGES .... ]])
        set(arch "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    endif()
    z_vcpkg_make_normalize_arch("${out_var}" "${arch}")
    set("${out_var}" "${${out_var}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_make_determine_target_arch out_var)
    list(LENGTH VCPKG_OSX_ARCHITECTURES osx_archs_num)
    if(osx_archs_num GREATER_EQUAL 2 AND VCPKG_TARGET_IS_OSX)
        set(${out_var} "universal")
    else()
        z_vcpkg_make_normalize_arch(${out_var} "${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    set("${out_var}" "${${out_var}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_make_prepare_compile_flags)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "DISABLE_CPPFLAGS;NO_FLAG_ESCAPING;DISABLE_MSVC_WRAPPERS" 
        "COMPILER_FRONTEND;CONFIG;FLAGS_OUT"
        "LANGUAGES"
    )

    z_vcpkg_unparsed_args(FATAL_ERROR)

    if(NOT DEFINED arg_LANGUAGES)
        set(arg_LANGUAGES "C" "CXX")
    endif()

    set(var_suffix "${arg_CONFIG}")
    set(CFLAGS "")
    set(CXXFLAGS "")

    # separate_aruments is needed to remove outer quotes from detected cmake variables.
    # (e.g. Android NDK has "--sysroot=...")
    foreach(lang IN LISTS arg_LANGUAGES)
        if(NOT "${VCPKG_COMBINED_${lang}_FLAGS_${var_suffix}}" STREQUAL "")
            separate_arguments(${lang}FLAGS NATIVE_COMMAND "${VCPKG_COMBINED_${lang}_FLAGS_${var_suffix}}")
        else()
            set(${lang}FLAGS "")
        endif()
        vcpkg_list(APPEND flags ${lang}FLAGS)
    endforeach()

    separate_arguments(LDFLAGS NATIVE_COMMAND "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_${var_suffix}}")
    separate_arguments(ARFLAGS NATIVE_COMMAND "${VCPKG_COMBINED_STATIC_LINKER_FLAGS_${var_suffix}}")
    set(RCFLAGS "${VCPKG_COMBINED_RC_FLAGS_${var_suffix}}")

    foreach(var IN ITEMS ABIFLAGS LDFLAGS ARFLAGS RCFLAGS)
        vcpkg_list(APPEND flags ${var})
    endforeach()
    
    set(ABIFLAGS "")
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
        vcpkg_list(APPEND ABIFLAGS "${pattern}")
        list(REMOVE_ITEM CFLAGS "${pattern}")
        list(REMOVE_ITEM CXXFLAGS "${pattern}")
        list(REMOVE_ITEM LDFLAGS "${pattern}")
        set(pattern "")
    endforeach()

    # Filter common CPPFLAGS out of CFLAGS and CXXFLAGS
    if(NOT arg_DISABLE_CPPFLAGS)
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

    # libtool tries to filter CFLAGS passed to the link stage via a allow list.

    # This approach is flawed since it fails to pass flags unknown to libtool
    # but required for linking to the link stage (e.g. -fsanitize=<x>).
    # libtool has an -R option so we need to guard against -RTC by using -Xcompiler.
    # While configuring there might be a lot of unknown compiler option warnings
    # due to that; just ignore them.
    set(compiler_flag_escape "")
    if(arg_COMPILER_FRONTEND STREQUAL "MSVC" AND NOT arg_NO_FLAG_ESCAPING)
        set(compiler_flag_escape "-Xcompiler")
    endif()
    if(compiler_flag_escape)
        list(TRANSFORM CFLAGS PREPEND "${compiler_flag_escape};")
        list(TRANSFORM CXXFLAGS PREPEND "${compiler_flag_escape};")
    endif()

    set(library_path_flag "${VCPKG_DETECTED_CMAKE_LIBRARY_PATH_FLAG}")
    set(linker_flag_escape "")
    if(arg_COMPILER_FRONTEND STREQUAL "MSVC" AND NOT arg_NO_FLAG_ESCAPING)
        # Removed by libtool
        set(linker_flag_escape "-Xlinker")
        if(NOT arg_DISABLE_MSVC_WRAPPERS)
            set(linker_flag_escape "-Xlinker -Xlinker -Xlinker")
        endif()
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            string(STRIP "$ENV{_LINK_} ${VCPKG_COMBINED_STATIC_LINKER_FLAGS_${var_suffix}}" LINK_ENV)
        else()
            string(STRIP "$ENV{_LINK_} ${VCPKG_COMBINED_SHARED_LINKER_FLAGS_${var_suffix}}" LINK_ENV)
        endif()
    endif()
    if(linker_flag_escape)
        string(STRIP "${linker_flag_escape}" linker_flag_escape_stripped)
        string(REPLACE " " ";" linker_flag_escape_stripped "${linker_flag_escape_stripped}")
        list(TRANSFORM LDFLAGS PREPEND "${linker_flag_escape_stripped};")   
    endif()
    string(REPLACE " " "\\ " current_installed_dir_escaped "${CURRENT_INSTALLED_DIR}")
    if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${var_suffix}}/lib/manual-link")
        vcpkg_list(PREPEND LDFLAGS "${linker_flag_escape}${library_path_flag}${current_installed_dir_escaped}${path_suffix_${var_suffix}}/lib/manual-link")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${var_suffix}}/lib")
        vcpkg_list(PREPEND LDFLAGS "${linker_flag_escape}${library_path_flag}${current_installed_dir_escaped}${path_suffix_${var_suffix}}/lib")
    endif()

    if(ARFLAGS AND NOT arg_COMPILER_FRONTEND STREQUAL "MSVC")
        # ARFLAGS need to know the command for creating an archive (Maybe needs user customization?)
        # or extract it from CMake via CMAKE_${lang}_ARCHIVE_CREATE ?
        # or from CMAKE_${lang}_${rule} with rule being one of CREATE_SHARED_MODULE CREATE_SHARED_LIBRARY LINK_EXECUTABLE
        vcpkg_list(PREPEND ARFLAGS "cr")
    elseif(NOT arg_DISABLE_MSVC_WRAPPERS AND arg_COMPILER_FRONTEND STREQUAL "MSVC")
        # The wrapper needs an action and that action needs to be defined AFTER all flags
        vcpkg_list(APPEND ARFLAGS "cr")
    endif()

    foreach(var IN LISTS flags)
        list(JOIN ${var} " " string)
        set("${var}_${var_suffix}" "${string}" PARENT_SCOPE)
        list(APPEND flags_out "${var}_${var_suffix}")
    endforeach()
    set("${arg_FLAGS_OUT}" "${flags_out}" PARENT_SCOPE)
endfunction()

### Prepare environment for configure
function(z_vcpkg_make_prepare_programs out_env)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "DISABLE_CPPFLAGS;DISABLE_MSVC_WRAPPERS"
        "CONFIG;BUILD_TRIPLET"
        "LANGUAGES"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)

    z_vcpkg_make_get_cmake_vars(LANGUAGES ${arg_LANGUAGES})

    macro(z_vcpkg_append_to_configure_environment inoutlist var defaultval)
        # Allows to overwrite settings in custom triplets via the environment
        if(DEFINED ENV{${var}})
            list(APPEND "${inoutlist}" "${var}='$ENV{${var}}'")
        else()
            list(APPEND "${inoutlist}" "${var}='${defaultval}'")
        endif()
    endmacro()

    set(configure_env "")
    # Remove full filepaths due to spaces and prepend filepaths to PATH (cross-compiling tools are unlikely on path by default)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(progs   C_COMPILER CXX_COMPILER AR
                    LINKER RANLIB OBJDUMP
                    STRIP NM DLLTOOL RC_COMPILER)
        list(TRANSFORM progs PREPEND "VCPKG_DETECTED_CMAKE_")
        foreach(prog IN LISTS progs)
            set(filepath "${${prog}}")
            if("${filepath}" MATCHES " " AND EXISTS "${${prog}}")
                cmake_path(GET filepath FILENAME "${prog}")
                vcpkg_insert_program_into_path("${filepath}")
            endif()
        endforeach()

        if (NOT arg_DISABLE_MSVC_WRAPPERS AND NOT VCPKG_TARGET_IS_MINGW)
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
            if(VCPKG_DETECTED_CMAKE_AR AND NOT "${VCPKG_DETECTED_CMAKE_AR}" MATCHES "llvm-ar")
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib ${VCPKG_DETECTED_CMAKE_AR}")
            elseif("${VCPKG_DETECTED_CMAKE_AR}" MATCHES "llvm-ar")
                # llvm-lib does not understand /EXTRACT so llvm-ar needs to be used. However, llvm-ar cannot use the ar-lib wrapper.
                z_vcpkg_append_to_configure_environment(configure_env AR "${VCPKG_DETECTED_CMAKE_AR}")
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
            z_vcpkg_append_to_configure_environment(configure_env RANLIB ": RANLIB-disabled")
        endif()
        if(VCPKG_DETECTED_CMAKE_OBJDUMP) #Objdump is required to make shared libraries. Otherwise define lt_cv_deplibs_check_method=pass_all
            z_vcpkg_append_to_configure_environment(configure_env OBJDUMP "${VCPKG_DETECTED_CMAKE_OBJDUMP}") # Trick to ignore the RANLIB call
        endif()
        if(VCPKG_DETECTED_CMAKE_STRIP) # If required set the ENV variable STRIP in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env STRIP "${VCPKG_DETECTED_CMAKE_STRIP}") 
        else()
            z_vcpkg_append_to_configure_environment(configure_env STRIP ": STRIP-disabled")
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

        if(NOT "ASM" IN_LIST arg_LANGUAGES )
            z_vcpkg_append_to_configure_environment(configure_env CCAS ": CCAS-disabled")   # If required set the ENV variable CCAS in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env AS ": AS-disabled")   # If required set the ENV variable AS in the portfile correctly

        else()
            set(ccas "${VCPKG_DETECTED_CMAKE_ASM_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_ASM_COMPILER_ID STREQUAL "MSVC")
                if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                    set(asmflags "--target=i686-pc-windows-msvc -m32")
                elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                    set(asmflags "--target=x86_64-pc-windows-msvc")
                elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
                    set(asmflags "--target=arm64-pc-windows-msvc")
                endif()
                vcpkg_find_acquire_program(CLANG)
                set(ccas "${CLANG}")
                if(ccas MATCHES " ")
                    cmake_path(GET ccas PARENT_PATH ccas_dir)
                    cmake_path(GET ccas FILENAME ccas_filename)
                    vcpkg_insert_program_into_path("${ccas_dir}")
                    set(ccas "${ccas_filename}")
                endif()
                string(APPEND ccas " ${asmflags}")
            endif() 
            z_vcpkg_append_to_configure_environment(configure_env CCAS "${ccas} -c")
            z_vcpkg_append_to_configure_environment(configure_env AS "${ccas} -c")
        endif()

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
            endif()
            z_vcpkg_append_to_configure_environment(configure_env "${envvar}" "${prog}")
            set(configure_env "${configure_env}" PARENT_SCOPE)
        endfunction()

        z_vcpkg_make_set_env(CC C_COMPILER ${ABIFLAGS_${arg_CONFIG}})
        z_vcpkg_make_set_env(CXX CXX_COMPILER ${ABIFLAGS_${arg_CONFIG}})
        if(NOT arg_BUILD_TRIPLET MATCHES "--host")
            z_vcpkg_make_set_env(CC_FOR_BUILD C_COMPILER ${ABIFLAGS_${arg_CONFIG}})
            z_vcpkg_make_set_env(CPP_FOR_BUILD C_COMPILER "-E" ${ABIFLAGS_${arg_CONFIG}})
            z_vcpkg_make_set_env(CXX_FOR_BUILD CXX_COMPILER ${ABIFLAGS_${arg_CONFIG}})
        else()
            set(ENV{CC_FOR_BUILD} "umask 0 | touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            set(ENV{CPP_FOR_BUILD} "umask 0 | touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            set(ENV{CXX_FOR_BUILD} "umask 0 | touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
        endif()
        if("ASM" IN_LIST arg_LANGUAGES)
            z_vcpkg_make_set_env(CCAS ASM_COMPILER "-c" ${ABIFLAGS_${arg_CONFIG}})
            z_vcpkg_make_set_env(AS ASM_COMPILER "-c" ${ABIFLAGS_${arg_CONFIG}})
        endif()
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
    list(JOIN configure_env " " configure_env)
    set("${out_env}" "${configure_env}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_make_prepare_link_flags)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "VCPKG_TRANSFORM_LIBS"
        "IN_OUT_VAR"
        ""
    )

    set(link_flags ${${arg_IN_OUT_VAR}})
    
    if(arg_VCPKG_TRANSFORM_LIBS)
        list(TRANSFORM link_flags REPLACE "[.](dll[.]lib|lib|a|so)$" "")

        if(VCPKG_TARGET_IS_WINDOWS)
            list(REMOVE_ITEM link_flags "uuid")
        endif()

        list(TRANSFORM link_flags REPLACE "^([^-].*)" "-l\\1")
        if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            # libtool must be told explicitly that there is no dynamic linkage for uuid.
            # The "-Wl,..." syntax is understood by libtool and gcc, but no by ld.
            list(TRANSFORM link_flags REPLACE "^-luuid\$" "-Wl,-Bstatic,-luuid,-Bdynamic")
        endif()
    endif()

    set(${arg_IN_OUT_VAR} ${link_flags} PARENT_SCOPE)
endfunction()

function(z_vcpkg_make_prepare_flags)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "DISABLE_CPPFLAGS;DISABLE_MSVC_WRAPPERS;NO_FLAG_ESCAPING" 
        "LIBS_OUT;FRONTEND_VARIANT_OUT;C_COMPILER_NAME"
        "LANGUAGES"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)

    z_vcpkg_make_get_cmake_vars(LANGUAGES ${arg_LANGUAGES})

    # ==== LIBS
    # TODO: Figure out what to do with other Languages like Fortran
    # Remove outer quotes from cmake variables which will be forwarded via makefile/shell variables
    # substituted into makefile commands (e.g. Android NDK has "--sysroot=...")
    separate_arguments(c_libs_list NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES}")
    separate_arguments(cxx_libs_list NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
    list(REMOVE_ITEM cxx_libs_list ${c_libs_list})
    set(all_libs_list ${cxx_libs_list} ${c_libs_list})

    # Do lib list transformation from name.lib to -lname if necessary
    set(vcpkg_transform_libs VCPKG_TRANSFORM_LIBS)
    if(VCPKG_DETECTED_CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC" AND (arg_NO_FLAG_ESCAPING))
      set(vcpkg_transform_libs "")
    endif()

    if(VCPKG_TARGET_IS_UWP)
        # Avoid libtool choke: "Warning: linker path does not have real file for library -lWindowsApp."
        # The problem with the choke is that libtool always falls back to built a static library even if a dynamic was requested.
        # Note: Env LIBPATH;LIB are on the search path for libtool by default on windows.
        # It even does unix/dos-short/unix transformation with the path to get rid of spaces.
        set(vcpkg_transform_libs "")
    endif()

    z_vcpkg_make_prepare_link_flags(
        IN_OUT_VAR all_libs_list 
        ${vcpkg_transform_libs}
    )

    if(all_libs_list)
        list(JOIN all_libs_list " " all_libs_string)
        if(DEFINED ENV{LIBS})
            set(ENV{LIBS} "$ENV{LIBS} ${all_libs_string}")
        else()
            set(ENV{LIBS} "${all_libs_string}")
        endif()
    endif()

    set("${arg_LIBS_OUT}" "${all_libs_string}" PARENT_SCOPE)

     # ==== /LIBS

     if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_backup_env_variables(VARS _CL_ _LINK_)
        # TODO: Should be CPP flags instead -> rewrite when vcpkg_determined_cmake_compiler_flags defined
        if(VCPKG_TARGET_IS_UWP)
            # Be aware that configure thinks it is crosscompiling due to:
            # error while loading shared libraries: VCRUNTIME140D_APP.dll: 
            # cannot open shared object file: No such file or directory
            # IMPORTANT: The only way to pass linker flags through libtool AND the compile wrapper 
            # is to use the CL and LINK environment variables !!!
            # (This is due to libtool and compiler wrapper using the same set of options to pass those variables around)
            file(TO_CMAKE_PATH "$ENV{VCToolsInstallDir}" VCToolsInstallDir)
            set(_replacement -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG "${VCPKG_COMBINED_CXX_FLAGS_DEBUG}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE "${VCPKG_COMBINED_CXX_FLAGS_RELEASE}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE "${VCPKG_COMBINED_C_FLAGS_RELEASE}")
            set(ENV{_CL_} "$ENV{_CL_} -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\"")
            set(ENV{_LINK_} "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        endif()
    endif()

    ####
    set(flags_opts "")
    if(DEFINED arg_LANGUAGES)
        list(APPEND flags_opts LANGUAGES ${arg_LANGUAGES})
    endif()

    if(arg_DISABLE_CPPFLAGS)
        list(APPEND flags_opts DISABLE_CPPFLAGS)
    endif()

    if(arg_DISABLE_MSVC_WRAPPERS)
        list(APPEND flags_opts DISABLE_MSVC_WRAPPERS)
    endif()

    if(arg_NO_FLAG_ESCAPING)
        list(APPEND flags_opts NO_FLAG_ESCAPING)
    endif()

    z_vcpkg_make_prepare_compile_flags(
        CONFIG RELEASE
        COMPILER_FRONTEND "${VCPKG_DETECTED_CMAKE_C_COMPILER_FRONTEND_VARIANT}"
        FLAGS_OUT release_flags_list
        ${flags_opts}
    )
    if(NOT DEFINED VCPKG_BUILD_TYPE)
        z_vcpkg_make_prepare_compile_flags(
            CONFIG DEBUG 
            COMPILER_FRONTEND "${VCPKG_DETECTED_CMAKE_C_COMPILER_FRONTEND_VARIANT}"
            FLAGS_OUT debug_flags_list
            ${flags_opts}
        )
    endif()

    foreach(flag IN LISTS release_flags_list debug_flags_list)
        set("${flag}" "${${flag}}" PARENT_SCOPE)
    endforeach()
    
    cmake_path(GET VCPKG_DETECTED_CMAKE_C_COMPILER FILENAME cname)
    set("${arg_C_COMPILER_NAME}" "${cname}" PARENT_SCOPE) # needed by z_vcpkg_make_get_configure_triplets
    set("${arg_FRONTEND_VARIANT_OUT}" "${VCPKG_DETECTED_CMAKE_C_COMPILER_FRONTEND_VARIANT}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_make_default_path_and_configure_options out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "AUTOMAKE" 
        "CONFIG;EXCLUDE_FILTER;INCLUDE_FILTER"
        ""
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)

    set(opts "")
    string(TOUPPER "${arg_CONFIG}" arg_CONFIG)

    z_vcpkg_make_set_common_vars()

    list(APPEND opts lt_cv_deplibs_check_method=pass_all)

    # Pre-processing windows configure requirements
    if (VCPKG_TARGET_IS_WINDOWS)
        # Other maybe interesting variables to control
        # COMPILE This is the command used to actually compile a C source file. The file name is appended to form the complete command line. 
        # LINK This is the command used to actually link a C program.
        # CXXCOMPILE The command used to actually compile a C++ source file. The file name is appended to form the complete command line. 
        # CXXLINK  The command used to actually link a C++ program. 

        # Variables not correctly detected by configure. In release builds.
        list(APPEND opts gl_cv_double_slash_root=yes
                         ac_cv_func_memmove=yes
                         ac_cv_func_memset=yes
            )

        if(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]64$")
            list(APPEND opts gl_cv_host_cpu_c_abi=no)
        endif()
    endif()

    # Set configure paths
    set(current_installed_dir_msys "${CURRENT_INSTALLED_DIR}")
    if(CMAKE_HOST_WIN32)
        string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" current_installed_dir_msys "${current_installed_dir_msys}")
    endif()
    vcpkg_list(APPEND opts "--prefix=${current_installed_dir_msys}${path_suffix_${arg_CONFIG}}")

    if(arg_CONFIG STREQUAL "RELEASE")
        # ${prefix} has an extra backslash to prevent early expansion when calling `bash -c configure "..."`.
        vcpkg_list(APPEND opts
                            # Important: These should all be relative to prefix!
                            "--bindir=\\\${prefix}/tools/${PORT}/bin"
                            "--sbindir=\\\${prefix}/tools/${PORT}/sbin"
                            "--libdir=\\\${prefix}/lib" # On some Linux distributions lib64 is the default
                            "--mandir=\\\${prefix}/share/${PORT}"
                            "--docdir=\\\${prefix}/share/${PORT}"
                            "--datarootdir=\\\${prefix}/share/${PORT}")
    else()
        vcpkg_list(APPEND opts
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
    if(NOT arg_AUTOMAKE)
        vcpkg_list(APPEND opts --disable-silent-rules --verbose)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_list(APPEND opts --enable-shared --disable-static)
    else()
        vcpkg_list(APPEND opts --disable-shared --enable-static)
    endif()

    if(DEFINED arg_EXCLUDE_FILTER)
        list(FILTER opts EXCLUDE REGEX "${arg_EXCLUDE_FILTER}")
    endif()

    if(DEFINED arg_INCLUDE_FILTER)
        list(FILTER opts INCLUDE REGEX "${arg_INCLUDE_FILTER}")
    endif()

    set("${out_var}" ${opts} PARENT_SCOPE)
endfunction()
