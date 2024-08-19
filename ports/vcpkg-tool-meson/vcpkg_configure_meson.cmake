function(z_vcpkg_meson_set_proglist_variables config_type)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(proglist MT AR)
    else()
        set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    endif()
    foreach(prog IN LISTS proglist)
        if(VCPKG_DETECTED_CMAKE_${prog})
            if(meson_${prog})
                string(TOUPPER "MESON_${meson_${prog}}" var_to_set)
                set("${var_to_set}" "${meson_${prog}} = ['${VCPKG_DETECTED_CMAKE_${prog}}']" PARENT_SCOPE)
            elseif(${prog} STREQUAL AR AND VCPKG_COMBINED_STATIC_LINKER_FLAGS_${config_type})
                # Probably need to move AR somewhere else
                string(TOLOWER "${prog}" proglower)
                z_vcpkg_meson_convert_compiler_flags_to_list(ar_flags "${VCPKG_COMBINED_STATIC_LINKER_FLAGS_${config_type}}")
                list(PREPEND ar_flags "${VCPKG_DETECTED_CMAKE_${prog}}")
                z_vcpkg_meson_convert_list_to_python_array(ar_flags ${ar_flags})
                set("MESON_AR" "${proglower} = ${ar_flags}" PARENT_SCOPE)
            else()
                string(TOUPPER "MESON_${prog}" var_to_set)
                string(TOLOWER "${prog}" proglower)
                set("${var_to_set}" "${proglower} = ['${VCPKG_DETECTED_CMAKE_${prog}}']" PARENT_SCOPE)
            endif()
        endif()
    endforeach()
    set(compilers "${arg_LANGUAGES}")
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND compilers RC)
    endif()
    set(meson_RC windres)
    set(meson_Fortran fortran)
    set(meson_CXX cpp)
    foreach(prog IN LISTS compilers)
        if(VCPKG_DETECTED_CMAKE_${prog}_COMPILER)
            string(TOUPPER "MESON_${prog}" var_to_set)
            if(meson_${prog})
                if(VCPKG_COMBINED_${prog}_FLAGS_${config_type})
                    # Need compiler flags in prog vars for sanity check.
                    z_vcpkg_meson_convert_compiler_flags_to_list(${prog}flags "${VCPKG_COMBINED_${prog}_FLAGS_${config_type}}")
                endif()
                list(PREPEND ${prog}flags "${VCPKG_DETECTED_CMAKE_${prog}_COMPILER}")
                list(FILTER ${prog}flags EXCLUDE REGEX "(-|/)nologo") # Breaks compiler detection otherwise
                z_vcpkg_meson_convert_list_to_python_array(${prog}flags ${${prog}flags})
                set("${var_to_set}" "${meson_${prog}} = ${${prog}flags}" PARENT_SCOPE)
                if (DEFINED VCPKG_DETECTED_CMAKE_${prog}_COMPILER_ID
                    AND NOT VCPKG_DETECTED_CMAKE_${prog}_COMPILER_ID MATCHES "^(GNU|Intel)$"
                    AND VCPKG_DETECTED_CMAKE_LINKER)
                    string(TOUPPER "MESON_${prog}_LD" var_to_set)
                    set(${var_to_set} "${meson_${prog}}_ld = ['${VCPKG_DETECTED_CMAKE_LINKER}']" PARENT_SCOPE)
                endif()
            else()
                if(VCPKG_COMBINED_${prog}_FLAGS_${config_type})
                     # Need compiler flags in prog vars for sanity check.
                    z_vcpkg_meson_convert_compiler_flags_to_list(${prog}flags "${VCPKG_COMBINED_${prog}_FLAGS_${config_type}}")
                endif()
                list(PREPEND ${prog}flags "${VCPKG_DETECTED_CMAKE_${prog}_COMPILER}")
                list(FILTER ${prog}flags EXCLUDE REGEX "(-|/)nologo") # Breaks compiler detection otherwise
                z_vcpkg_meson_convert_list_to_python_array(${prog}flags ${${prog}flags})
                string(TOLOWER "${prog}" proglower)
                set("${var_to_set}" "${proglower} = ${${prog}flags}" PARENT_SCOPE)
                if (DEFINED VCPKG_DETECTED_CMAKE_${prog}_COMPILER_ID
                    AND NOT VCPKG_DETECTED_CMAKE_${prog}_COMPILER_ID MATCHES "^(GNU|Intel)$"
                    AND VCPKG_DETECTED_CMAKE_LINKER)
                    string(TOUPPER "MESON_${prog}_LD" var_to_set)
                    set(${var_to_set} "${proglower}_ld = ['${VCPKG_DETECTED_CMAKE_LINKER}']" PARENT_SCOPE)
                endif()
            endif()
        endif()
    endforeach()
endfunction()

function(z_vcpkg_meson_convert_compiler_flags_to_list out_var compiler_flags)
    separate_arguments(cmake_list NATIVE_COMMAND "${compiler_flags}")
    list(TRANSFORM cmake_list REPLACE ";" [[\\;]])
    set("${out_var}" "${cmake_list}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_meson_convert_list_to_python_array out_var)
    z_vcpkg_function_arguments(flag_list 1)
    vcpkg_list(REMOVE_ITEM flag_list "") # remove empty elements if any
    vcpkg_list(JOIN flag_list "', '" flag_list)
    set("${out_var}" "['${flag_list}']" PARENT_SCOPE)
endfunction()

# Generates the required compiler properties for meson
function(z_vcpkg_meson_set_flags_variables config_type)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        set(libpath_flag /LIBPATH:)
    else()
        set(libpath_flag -L)
    endif()
    if(config_type STREQUAL "DEBUG")
        set(path_suffix "/debug")
    else()
        set(path_suffix "")
    endif()

    set(includepath "-I${CURRENT_INSTALLED_DIR}/include")
    set(libpath "${libpath_flag}${CURRENT_INSTALLED_DIR}${path_suffix}/lib")

    foreach(lang IN LISTS arg_LANGUAGES)
        z_vcpkg_meson_convert_compiler_flags_to_list(${lang}flags "${VCPKG_COMBINED_${lang}_FLAGS_${config_type}}")
        if(lang MATCHES "^(C|CXX)$")
            vcpkg_list(APPEND ${lang}flags "${includepath}")
        endif()
        z_vcpkg_meson_convert_list_to_python_array(${lang}flags ${${lang}flags})
        set(lang_mapping "${lang}")
        if(lang STREQUAL "Fortran")
            set(lang_mapping "FC")
        endif()
        string(TOLOWER "${lang_mapping}" langlower)
        if(lang STREQUAL "CXX")
            set(langlower cpp)
        endif()
        set(MESON_${lang_mapping}FLAGS "${langlower}_args = ${${lang}flags}\n")
        set(linker_flags "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_${config_type}}")
        z_vcpkg_meson_convert_compiler_flags_to_list(linker_flags "${linker_flags}")
        vcpkg_list(APPEND linker_flags "${libpath}")
        z_vcpkg_meson_convert_list_to_python_array(linker_flags ${linker_flags})
        string(APPEND MESON_${lang_mapping}FLAGS "${langlower}_link_args = ${linker_flags}\n")
        set(MESON_${lang_mapping}FLAGS "${MESON_${lang_mapping}FLAGS}" PARENT_SCOPE)
    endforeach()
endfunction()

function(z_vcpkg_get_build_and_host_system build_system host_system is_cross) #https://mesonbuild.com/Cross-compilation.html
    set(build_unknown FALSE)
    if(CMAKE_HOST_WIN32)
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(build_arch $ENV{PROCESSOR_ARCHITEW6432})
        else()
            set(build_arch $ENV{PROCESSOR_ARCHITECTURE})
        endif()
        if(build_arch MATCHES "(amd|AMD)64")
            set(build_cpu_fam x86_64)
            set(build_cpu x86_64)
        elseif(build_arch MATCHES "(x|X)86")
            set(build_cpu_fam x86)
            set(build_cpu i686)
        elseif(build_arch MATCHES "^(ARM|arm)64$")
            set(build_cpu_fam aarch64)
            set(build_cpu armv8)
        elseif(build_arch MATCHES "^(ARM|arm)$")
            set(build_cpu_fam arm)
            set(build_cpu armv7hl)
        else()
            if(NOT DEFINED VCPKG_MESON_CROSS_FILE OR NOT DEFINED VCPKG_MESON_NATIVE_FILE)
                message(WARNING "Unsupported build architecture ${build_arch}! Please set VCPKG_MESON_(CROSS|NATIVE)_FILE to a meson file containing the build_machine entry!")
            endif()
            set(build_unknown TRUE)
        endif()
    elseif(CMAKE_HOST_UNIX)
        # at this stage, CMAKE_HOST_SYSTEM_PROCESSOR is not defined
        execute_process(
            COMMAND uname -m
            OUTPUT_VARIABLE MACHINE
            OUTPUT_STRIP_TRAILING_WHITESPACE
            COMMAND_ERROR_IS_FATAL ANY)

        # Show real machine architecture to visually understand whether we are in a native Apple Silicon terminal or running under Rosetta emulation
        debug_message("Machine: ${MACHINE}")

        if(MACHINE MATCHES "arm64|aarch64")
            set(build_cpu_fam aarch64)
            set(build_cpu armv8)
        elseif(MACHINE MATCHES "armv7h?l")
            set(build_cpu_fam arm)
            set(build_cpu ${MACHINE})
        elseif(MACHINE MATCHES "x86_64|amd64")
            set(build_cpu_fam x86_64)
            set(build_cpu x86_64)
        elseif(MACHINE MATCHES "x86|i686")
            set(build_cpu_fam x86)
            set(build_cpu i686)
        elseif(MACHINE MATCHES "i386")
            set(build_cpu_fam x86)
            set(build_cpu i386)
        elseif(MACHINE MATCHES "loongarch64")
            set(build_cpu_fam loongarch64)
            set(build_cpu loongarch64)
        else()
            # https://github.com/mesonbuild/meson/blob/master/docs/markdown/Reference-tables.md#cpu-families
            if(NOT DEFINED VCPKG_MESON_CROSS_FILE OR NOT DEFINED VCPKG_MESON_NATIVE_FILE)
                message(WARNING "Unhandled machine: ${MACHINE}! Please set VCPKG_MESON_(CROSS|NATIVE)_FILE to a meson file containing the build_machine entry!")
            endif()
            set(build_unknown TRUE)
        endif()
    else()
        if(NOT DEFINED VCPKG_MESON_CROSS_FILE OR NOT DEFINED VCPKG_MESON_NATIVE_FILE)
            message(WARNING "Failed to detect the build architecture! Please set VCPKG_MESON_(CROSS|NATIVE)_FILE to a meson file containing the build_machine entry!")
        endif()
        set(build_unknown TRUE)
    endif()

    set(build "[build_machine]\n") # Machine the build is performed on
    string(APPEND build "endian = 'little'\n")
    if(CMAKE_HOST_WIN32)
        string(APPEND build "system = 'windows'\n")
    elseif(CMAKE_HOST_APPLE)
        string(APPEND build "system = 'darwin'\n")
    elseif(CYGWIN)
        string(APPEND build "system = 'cygwin'\n")
    elseif(CMAKE_HOST_UNIX)
        string(APPEND build "system = 'linux'\n")
    else()
        set(build_unknown TRUE)
    endif()

    if(DEFINED build_cpu_fam)
        string(APPEND build "cpu_family = '${build_cpu_fam}'\n")
    endif()
    if(DEFINED build_cpu)
        string(APPEND build "cpu = '${build_cpu}'")
    endif()
    if(NOT build_unknown)
        set(${build_system} "${build}" PARENT_SCOPE)
    endif()

    set(host_unkown FALSE)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(amd|AMD|x|X)64")
        set(host_cpu_fam x86_64)
        set(host_cpu x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)86")
        set(host_cpu_fam x86)
        set(host_cpu i686)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)64$")
        set(host_cpu_fam aarch64)
        set(host_cpu armv8)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)$")
        set(host_cpu_fam arm)
        set(host_cpu armv7hl)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "loongarch64")
        set(host_cpu_fam loongarch64)
        set(host_cpu loongarch64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "wasm32")
        set(host_cpu_fam wasm32)
        set(host_cpu wasm32)
    else()
        if(NOT DEFINED VCPKG_MESON_CROSS_FILE OR NOT DEFINED VCPKG_MESON_NATIVE_FILE)
            message(WARNING "Unsupported target architecture ${VCPKG_TARGET_ARCHITECTURE}! Please set VCPKG_MESON_(CROSS|NATIVE)_FILE to a meson file containing the host_machine entry!" )
        endif()
        set(host_unkown TRUE)
    endif()

    set(host "[host_machine]\n") # host=target in vcpkg. 
    string(APPEND host "endian = 'little'\n")
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_TARGET_IS_MINGW OR VCPKG_TARGET_IS_UWP)
        set(meson_system_name "windows")
    else()
        string(TOLOWER "${VCPKG_CMAKE_SYSTEM_NAME}" meson_system_name)
    endif()
    string(APPEND host "system = '${meson_system_name}'\n")
    string(APPEND host "cpu_family = '${host_cpu_fam}'\n")
    string(APPEND host "cpu = '${host_cpu}'")
    if(NOT host_unkown)
        set(${host_system} "${host}" PARENT_SCOPE)
    endif()

    if(NOT build_cpu_fam MATCHES "${host_cpu_fam}"
       OR VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_UWP
       OR (VCPKG_TARGET_IS_MINGW AND NOT CMAKE_HOST_WIN32))
        set(${is_cross} TRUE PARENT_SCOPE)
    endif()
endfunction()

function(z_vcpkg_meson_setup_extra_windows_variables config_type)
    ## b_vscrt
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(crt_type "mt")
    else()
        set(crt_type "md")
    endif()
    if(config_type STREQUAL "DEBUG")
        set(crt_type "${crt_type}d")
    endif()
    set(MESON_VSCRT_LINKAGE "b_vscrt = '${crt_type}'" PARENT_SCOPE)
    ## winlibs
    separate_arguments(c_winlibs NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES}")
    separate_arguments(cpp_winlibs NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
    z_vcpkg_meson_convert_list_to_python_array(c_winlibs ${c_winlibs})
    z_vcpkg_meson_convert_list_to_python_array(cpp_winlibs ${cpp_winlibs})
    set(MESON_WINLIBS "c_winlibs = ${c_winlibs}\n")
    string(APPEND MESON_WINLIBS "cpp_winlibs = ${cpp_winlibs}")
    set(MESON_WINLIBS "${MESON_WINLIBS}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_meson_setup_variables config_type)
    set(meson_var_list VSCRT_LINKAGE WINLIBS MT AR RC C C_LD CXX CXX_LD OBJC OBJC_LD OBJCXX OBJCXX_LD FC FC_LD WINDRES CFLAGS CXXFLAGS OBJCFLAGS OBJCXXFLAGS FCFLAGS SHARED_LINKER_FLAGS)
    foreach(var IN LISTS meson_var_list)
        set(MESON_${var} "")
    endforeach()

    if(VCPKG_TARGET_IS_WINDOWS)
        z_vcpkg_meson_setup_extra_windows_variables("${config_type}")
    endif()

    z_vcpkg_meson_set_proglist_variables("${config_type}")
    z_vcpkg_meson_set_flags_variables("${config_type}")

    foreach(var IN LISTS meson_var_list)
        set(MESON_${var} "${MESON_${var}}" PARENT_SCOPE)
    endforeach()
endfunction()

function(vcpkg_generate_meson_cmd_args)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        ""
        "OUTPUT;CONFIG"
        "OPTIONS;LANGUAGES;ADDITIONAL_BINARIES;ADDITIONAL_PROPERTIES"
    )

    if(NOT arg_LANGUAGES)
        set(arg_LANGUAGES C CXX)
    endif()

    vcpkg_list(JOIN arg_ADDITIONAL_BINARIES "\n" MESON_ADDITIONAL_BINARIES)
    vcpkg_list(JOIN arg_ADDITIONAL_PROPERTIES "\n" MESON_ADDITIONAL_PROPERTIES)

    set(buildtype "${arg_CONFIG}")

    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        z_vcpkg_select_default_vcpkg_chainload_toolchain()
    endif()
    vcpkg_cmake_get_vars(cmake_vars_file)
    debug_message("Including cmake vars from: ${cmake_vars_file}")
    include("${cmake_vars_file}")

    vcpkg_list(APPEND arg_OPTIONS --backend ninja --wrap-mode nodownload -Doptimization=plain)

    z_vcpkg_get_build_and_host_system(MESON_HOST_MACHINE MESON_BUILD_MACHINE IS_CROSS)

    if(arg_CONFIG STREQUAL "DEBUG")
      set(suffix "dbg")
    else()
      string(SUBSTRING "${arg_CONFIG}" 0 3 suffix)
      string(TOLOWER "${suffix}" suffix)
    endif()
    set(meson_input_file_${buildtype} "${CURRENT_BUILDTREES_DIR}/meson-${TARGET_TRIPLET}-${suffix}.log")

    if(IS_CROSS)
        # VCPKG_CROSSCOMPILING is not used since it regresses a lot of ports in x64-windows-x triplets
        # For consistency this should proably be changed in the future?
        vcpkg_list(APPEND arg_OPTIONS --native "${SCRIPTS}/buildsystems/meson/none.txt")
        vcpkg_list(APPEND arg_OPTIONS --cross "${meson_input_file_${buildtype}}")
    else()
        vcpkg_list(APPEND arg_OPTIONS --native "${meson_input_file_${buildtype}}")
    endif()

    # User provided cross/native files
    if(VCPKG_MESON_NATIVE_FILE)
        vcpkg_list(APPEND arg_OPTIONS --native "${VCPKG_MESON_NATIVE_FILE}")
    endif()
    if(VCPKG_MESON_NATIVE_FILE_${buildtype})
        vcpkg_list(APPEND arg_OPTIONS --native "${VCPKG_MESON_NATIVE_FILE_${buildtype}}")
    endif()
    if(VCPKG_MESON_CROSS_FILE)
        vcpkg_list(APPEND arg_OPTIONS --cross "${VCPKG_MESON_CROSS_FILE}")
    endif()
    if(VCPKG_MESON_CROSS_FILE_${buildtype})
        vcpkg_list(APPEND arg_OPTIONS --cross "${VCPKG_MESON_CROSS_FILE_${buildtype}}")
    endif()

    vcpkg_list(APPEND arg_OPTIONS --libdir lib) # else meson install into an architecture describing folder
    vcpkg_list(APPEND arg_OPTIONS --pkgconfig.relocatable)

    if(arg_CONFIG STREQUAL "RELEASE")
      vcpkg_list(APPEND arg_OPTIONS -Ddebug=false --prefix "${CURRENT_PACKAGES_DIR}")
      vcpkg_list(APPEND arg_OPTIONS "--pkg-config-path;['${CURRENT_INSTALLED_DIR}/lib/pkgconfig','${CURRENT_INSTALLED_DIR}/share/pkgconfig']")
      if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_list(APPEND arg_OPTIONS "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}/share']")
      else()
        vcpkg_list(APPEND arg_OPTIONS "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/debug']")
      endif()
    elseif(arg_CONFIG STREQUAL "DEBUG")
      vcpkg_list(APPEND arg_OPTIONS -Ddebug=true --prefix "${CURRENT_PACKAGES_DIR}/debug" --includedir ../include)
      vcpkg_list(APPEND arg_OPTIONS "--pkg-config-path;['${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig','${CURRENT_INSTALLED_DIR}/share/pkgconfig']")
      if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_list(APPEND arg_OPTIONS "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/share']")
      else()
        vcpkg_list(APPEND arg_OPTIONS "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}']")
      endif()
    else()
      message(FATAL_ERROR "Unknown configuration. Only DEBUG and RELEASE are valid values.")
    endif()

    # Allow overrides / additional configuration variables from triplets
    if(DEFINED VCPKG_MESON_CONFIGURE_OPTIONS)
        vcpkg_list(APPEND arg_OPTIONS ${VCPKG_MESON_CONFIGURE_OPTIONS})
    endif()
    if(DEFINED VCPKG_MESON_CONFIGURE_OPTIONS_${buildtype})
        vcpkg_list(APPEND arg_OPTIONS ${VCPKG_MESON_CONFIGURE_OPTIONS_${buildtype}})
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(MESON_DEFAULT_LIBRARY shared)
    else()
        set(MESON_DEFAULT_LIBRARY static)
    endif()
    set(MESON_CMAKE_BUILD_TYPE "${cmake_build_type_${buildtype}}")
    z_vcpkg_meson_setup_variables(${buildtype})
    configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/meson.template.in" "${meson_input_file_${buildtype}}" @ONLY)
    set("${arg_OUTPUT}" ${arg_OPTIONS} PARENT_SCOPE)
endfunction()

function(vcpkg_configure_meson)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "NO_PKG_CONFIG"
        "SOURCE_PATH"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;LANGUAGES;ADDITIONAL_BINARIES;ADDITIONAL_NATIVE_BINARIES;ADDITIONAL_CROSS_BINARIES;ADDITIONAL_PROPERTIES"
    )

    if(DEFINED arg_ADDITIONAL_NATIVE_BINARIES OR DEFINED arg_ADDITIONAL_CROSS_BINARIES)
        message(WARNING "Options ADDITIONAL_(NATIVE|CROSS)_BINARIES have been deprecated. Only use ADDITIONAL_BINARIES!")
    endif()
    vcpkg_list(APPEND arg_ADDITIONAL_BINARIES ${arg_ADDITIONAL_NATIVE_BINARIES} ${arg_ADDITIONAL_CROSS_BINARIES})
    vcpkg_list(REMOVE_DUPLICATES arg_ADDITIONAL_BINARIES)

    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    vcpkg_find_acquire_program(MESON)

    get_filename_component(CMAKE_PATH "${CMAKE_COMMAND}" DIRECTORY)
    vcpkg_add_to_path("${CMAKE_PATH}") # Make CMake invokeable for Meson

    vcpkg_find_acquire_program(NINJA)

    if(NOT arg_NO_PKG_CONFIG)
      vcpkg_find_acquire_program(PKGCONFIG)
      set(ENV{PKG_CONFIG} "${PKGCONFIG}")
    endif()

    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")

    set(buildtypes "")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(buildname "DEBUG")
        set(cmake_build_type_${buildname} "Debug")
        vcpkg_list(APPEND buildtypes "${buildname}")
        set(path_suffix_${buildname} "debug/")
        set(suffix_${buildname} "dbg")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(buildname "RELEASE")
        set(cmake_build_type_${buildname} "Release")
        vcpkg_list(APPEND buildtypes "${buildname}")
        set(path_suffix_${buildname} "")
        set(suffix_${buildname} "rel")
    endif()

    # configure build
    foreach(buildtype IN LISTS buildtypes)
        message(STATUS "Configuring ${TARGET_TRIPLET}-${suffix_${buildtype}}")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}")

        vcpkg_generate_meson_cmd_args(
          OUTPUT cmd_args
          CONFIG ${buildtype}
          LANGUAGES ${arg_LANGUAGES}
          OPTIONS ${arg_OPTIONS} ${arg_OPTIONS_${buildtype}}
          ADDITIONAL_BINARIES ${arg_ADDITIONAL_BINARIES}
          ADDITIONAL_PROPERTIES ${arg_ADDITIONAL_PROPERTIES}
        )

        vcpkg_execute_required_process(
            COMMAND ${MESON} setup ${cmd_args} ${arg_SOURCE_PATH}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}"
            LOGNAME config-${TARGET_TRIPLET}-${suffix_${buildtype}}
            SAVE_LOG_FILES
                meson-logs/meson-log.txt
                meson-info/intro-dependencies.json
                meson-logs/install-log.txt
        )

        message(STATUS "Configuring ${TARGET_TRIPLET}-${suffix_${buildtype}} done")
    endforeach()
endfunction()
