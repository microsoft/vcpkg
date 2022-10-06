function(z_vcpkg_append_proglist var_to_append additional_binaries)
    string(APPEND "${var_to_append}" "[binaries]\n")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(proglist MT AR)
    else()
        set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    endif()
    foreach(prog IN LISTS proglist)
        if(VCPKG_DETECTED_CMAKE_${prog})
            if(meson_${prog})
                string(APPEND "${var_to_append}" "${meson_${prog}} = '${VCPKG_DETECTED_CMAKE_${prog}}'\n")
            else()
                string(TOLOWER "${prog}" proglower)
                string(APPEND "${var_to_append}" "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}}'\n")
            endif()
        endif()
    endforeach()
    set(programs C CXX RC)
    set(meson_RC windres)
    set(meson_CXX cpp)
    foreach(prog IN LISTS programs)
        if(VCPKG_DETECTED_CMAKE_${prog}_COMPILER)
            if(meson_${prog})
                string(APPEND "${var_to_append}" "${meson_${prog}} = '${VCPKG_DETECTED_CMAKE_${prog}_COMPILER}'\n")
            else()
                string(TOLOWER "${prog}" proglower)
                string(APPEND "${var_to_append}" "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}_COMPILER}'\n")
            endif()
        endif()
    endforeach()
    if(VCPKG_DETECTED_CMAKE_LINKER AND VCPKG_TARGET_IS_WINDOWS)
        # for gcc and icc the linker flag -fuse-ld is used. See https://github.com/mesonbuild/meson/issues/8647#issuecomment-878673456
        if (NOT VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "^(GNU|Intel)$")
            string(APPEND "${var_to_append}" "c_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
        endif()
    endif()
    if(VCPKG_DETECTED_CMAKE_LINKER AND VCPKG_TARGET_IS_WINDOWS)
        # for gcc and icc the linker flag -fuse-ld is used. See https://github.com/mesonbuild/meson/issues/8647#issuecomment-878673456
        if (NOT VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "^(GNU|Intel)$")
            string(APPEND "${var_to_append}" "cpp_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
        endif()
    endif()

    get_filename_component(CMAKE_PATH "${CMAKE_COMMAND}" DIRECTORY)
    vcpkg_add_to_path("${CMAKE_PATH}" PREPEND) # Make CMake invokeable for Meson
    string(APPEND "${var_to_append}" "cmake = '${CMAKE_COMMAND}'\n")

    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
    vcpkg_add_to_path("${PYTHON3_DIR}")
    string(APPEND "${var_to_append}" "python = '${PYTHON3}'\n")

    vcpkg_find_acquire_program(NINJA)
    get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${NINJA_PATH}") # Prepend to use the correct ninja. 
    # string(APPEND "${var_to_append}" "ninja = '${NINJA}'\n") # This does not work due to meson issues
    
    foreach(additional_binary IN LISTS additional_binaries)
        string(APPEND "${var_to_append}" "${additional_binary}\n")
    endforeach()
    set("${var_to_append}" "${${var_to_append}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_meson_generate_native_file additional_binaries) #https://mesonbuild.com/Native-environments.html
    set(native_config "")
    z_vcpkg_append_proglist(native_config "${additional_binaries}")

    string(APPEND native_config "[built-in options]\n") #https://mesonbuild.com/Builtin-options.html
    if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe")
        # This is currently wrongly documented in the meson docs or buggy. The docs say: 'none' = no flags
        # In reality however 'none' tries to deactivate eh and meson passes the flags for it resulting in a lot of warnings
        # about overriden flags. Until this is fixed in meson vcpkg should not pass this here.
        # string(APPEND native_config "cpp_eh='none'\n") # To make sure meson is not adding eh flags by itself using msvc
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        set(c_winlibs "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES}")
        set(cpp_winlibs "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        foreach(libvar IN ITEMS c_winlibs cpp_winlibs)
            string(REGEX REPLACE "( |^)(-|/)" [[;\2]] "${libvar}" "${${libvar}}")
            string(REPLACE ".lib " ".lib;" "${libvar}" "${${libvar}}")
            vcpkg_list(REMOVE_ITEM "${libvar}" "")
            vcpkg_list(JOIN "${libvar}" "', '" "${libvar}")
            string(APPEND native_config "${libvar} = ['${${libvar}}']\n")
        endforeach()
    endif()

    set(native_config_name "${CURRENT_BUILDTREES_DIR}/meson-native-${TARGET_TRIPLET}.log")
    set(vcpkg_meson_native_file "${native_config_name}" PARENT_SCOPE)
    file(WRITE "${native_config_name}" "${native_config}")
endfunction()

function(z_vcpkg_meson_convert_compiler_flags_to_list out_var compiler_flags)
    string(REPLACE ";" [[\;]] tmp_var "${compiler_flags}")
    string(REGEX REPLACE [=[( +|^)((\"(\\"|[^"])+"|\\"|\\ |[^ ])+)]=] ";\\2" tmp_var "${tmp_var}")
    vcpkg_list(POP_FRONT tmp_var) # The first element is always empty due to the above replacement
    list(TRANSFORM tmp_var STRIP) # Strip leading trailing whitespaces from each element in the list.
    set("${out_var}" "${tmp_var}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_meson_convert_list_to_python_array out_var)
    z_vcpkg_function_arguments(flag_list 1)
    vcpkg_list(REMOVE_ITEM flag_list "") # remove empty elements if any
    vcpkg_list(JOIN flag_list "', '" flag_list)
    set("${out_var}" "['${flag_list}']" PARENT_SCOPE)
endfunction()

# Generates the required compiler properties for meson
function(z_vcpkg_meson_generate_flags_properties_string out_var config_type)
    set(result "")

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

    set(libpath "${libpath_flag}${CURRENT_INSTALLED_DIR}${path_suffix}/lib")

    z_vcpkg_meson_convert_compiler_flags_to_list(cflags "${VCPKG_DETECTED_CMAKE_C_FLAGS_${config_type}}")
    vcpkg_list(APPEND cflags "-I${CURRENT_INSTALLED_DIR}/include")
    z_vcpkg_meson_convert_list_to_python_array(cflags ${cflags})
    string(APPEND result "c_args = ${cflags}\n")

    z_vcpkg_meson_convert_compiler_flags_to_list(cxxflags "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${config_type}}")
    vcpkg_list(APPEND cxxflags "-I${CURRENT_INSTALLED_DIR}/include")
    z_vcpkg_meson_convert_list_to_python_array(cxxflags ${cxxflags})
    string(APPEND result "cpp_args = ${cxxflags}\n")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(linker_flags "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${config_type}}")
    else()
        set(linker_flags "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${config_type}}")
    endif()
    z_vcpkg_meson_convert_compiler_flags_to_list(linker_flags "${linker_flags}")
    if(VCPKG_TARGET_IS_OSX)
        # macOS - append arch and isysroot if cross-compiling
        if(NOT "${VCPKG_OSX_ARCHITECTURES}" STREQUAL "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
            foreach(arch IN LISTS VCPKG_OSX_ARCHITECTURES)
                vcpkg_list(APPEND linker_flags -arch "${arch}")
            endforeach()
        endif()
        if(VCPKG_DETECTED_CMAKE_OSX_SYSROOT)
            vcpkg_list(APPEND linker_flags -isysroot "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
        endif()    
    endif()
    vcpkg_list(APPEND linker_flags "${libpath}")
    z_vcpkg_meson_convert_list_to_python_array(linker_flags ${linker_flags})
    string(APPEND result "c_link_args = ${linker_flags}\n")
    string(APPEND result "cpp_link_args = ${linker_flags}\n")
    set("${out_var}" "${result}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_meson_generate_native_file_config config_type) #https://mesonbuild.com/Native-environments.html
    set(native_file "[properties]\n") #https://mesonbuild.com/Builtin-options.html
    #Setup CMake properties
    string(APPEND native_file "cmake_toolchain_file  = '${SCRIPTS}/buildsystems/vcpkg.cmake'\n")
    string(APPEND native_file "[cmake]\n")

    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        z_vcpkg_select_default_vcpkg_chainload_toolchain()
    endif()

    string(APPEND native_file "VCPKG_TARGET_TRIPLET = '${TARGET_TRIPLET}'\n")
    string(APPEND native_file "VCPKG_CHAINLOAD_TOOLCHAIN_FILE = '${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}'\n")
    string(APPEND native_file "VCPKG_CRT_LINKAGE = '${VCPKG_CRT_LINKAGE}'\n")

    string(APPEND native_file "[built-in options]\n")
    z_vcpkg_meson_generate_flags_properties_string(native_properties "${config_type}")
    string(APPEND native_file "${native_properties}")
    if(VCPKG_TARGET_IS_WINDOWS)
        if(VCPKG_CRT_LINKAGE STREQUAL "static")
            set(crt_type mt)
        else()
            set(crt_type md)
        endif()
        if("${config_type}" STREQUAL "DEBUG")
            string(APPEND crt_type "d")
        endif()
        string(APPEND native_file "b_vscrt = '${crt_type}'\n")
    endif()
    string(TOLOWER "${config_type}" lowerconfig)
    set(native_config_name "${CURRENT_BUILDTREES_DIR}/meson-native-${TARGET_TRIPLET}-${lowerconfig}.log")
    file(WRITE "${native_config_name}" "${native_file}")
    set("vcpkg_meson_native_file_${config_type}" "${native_config_name}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_meson_generate_cross_file additional_binaries) #https://mesonbuild.com/Cross-compilation.html
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
            message(FATAL_ERROR "Unsupported host architecture ${build_arch}!")
        endif()
    elseif(CMAKE_HOST_UNIX)
        # at this stage, CMAKE_HOST_SYSTEM_PROCESSOR is not defined
        execute_process(
            COMMAND uname -m
            OUTPUT_VARIABLE MACHINE
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
            message(FATAL_ERROR "Unhandled machine: ${MACHINE}")
        endif()
    else()
        message(FATAL_ERROR "Failed to detect the host architecture!")
    endif()

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
        message(FATAL_ERROR "Unsupported target architecture ${VCPKG_TARGET_ARCHITECTURE}!" )
    endif()

    set(cross_file "")
    z_vcpkg_append_proglist(cross_file "${additional_binaries}")

    string(APPEND cross_file "[properties]\n")

    string(APPEND cross_file "[host_machine]\n")
    string(APPEND cross_file "endian = 'little'\n")
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_TARGET_IS_MINGW OR VCPKG_TARGET_IS_UWP)
        set(meson_system_name "windows")
    else()
        string(TOLOWER "${VCPKG_CMAKE_SYSTEM_NAME}" meson_system_name)
    endif()
    string(APPEND cross_file "system = '${meson_system_name}'\n")
    string(APPEND cross_file "cpu_family = '${host_cpu_fam}'\n")
    string(APPEND cross_file "cpu = '${host_cpu}'\n")

    string(APPEND cross_file "[build_machine]\n")
    string(APPEND cross_file "endian = 'little'\n")
    if(WIN32)
        string(APPEND cross_file "system = 'windows'\n")
    elseif(DARWIN)
        string(APPEND cross_file "system = 'darwin'\n")
    else()
        string(APPEND cross_file "system = 'linux'\n")
    endif()

    if(DEFINED build_cpu_fam)
        string(APPEND cross_file "cpu_family = '${build_cpu_fam}'\n")
    endif()
    if(DEFINED build_cpu)
        string(APPEND cross_file "cpu = '${build_cpu}'\n")
    endif()

    if(NOT build_cpu_fam MATCHES "${host_cpu_fam}"
       OR VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_UWP
       OR (VCPKG_TARGET_IS_MINGW AND NOT WIN32))
        set(native_config_name "${CURRENT_BUILDTREES_DIR}/meson-cross-${TARGET_TRIPLET}.log")
        set(vcpkg_meson_cross_file "${native_config_name}" PARENT_SCOPE)
        file(WRITE "${native_config_name}" "${cross_file}")
    endif()
endfunction()

function(z_vcpkg_meson_generate_cross_file_config config_type) #https://mesonbuild.com/Native-environments.html
    set(cross_${config_type}_log "[properties]\n") #https://mesonbuild.com/Builtin-options.html
    string(APPEND cross_${config_type}_log "[built-in options]\n")
    z_vcpkg_meson_generate_flags_properties_string(cross_properties ${config_type})
    string(APPEND cross_${config_type}_log "${cross_properties}")
    if(VCPKG_TARGET_IS_WINDOWS)
        if(VCPKG_CRT_LINKAGE STREQUAL "static")
            set(crt_type mt)
        else()
            set(crt_type md)
        endif()
        if(${config_type} STREQUAL "DEBUG")
            set(crt_type ${crt_type}d)
        endif()
        set(c_winlibs "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES}")
        set(cpp_winlibs "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        foreach(libvar IN ITEMS c_winlibs cpp_winlibs)
            string(REGEX REPLACE "( |^)(-|/)" [[;\2]] "${libvar}" "${${libvar}}")
            string(REPLACE ".lib " ".lib;" "${libvar}" "${${libvar}}")
            vcpkg_list(REMOVE_ITEM "${libvar}" "")
            vcpkg_list(JOIN "${libvar}" "', '" "${libvar}")
            string(APPEND cross_${config_type}_log "${libvar} = ['${${libvar}}']\n")
        endforeach()
        string(APPEND cross_${config_type}_log "b_vscrt = '${crt_type}'\n")
    endif()
    string(TOLOWER "${config_type}" lowerconfig)
    set(native_config_name "${CURRENT_BUILDTREES_DIR}/meson-cross-${TARGET_TRIPLET}-${lowerconfig}.log")
    set(VCPKG_MESON_CROSS_FILE_${config_type} "${native_config_name}" PARENT_SCOPE)
    file(WRITE "${native_config_name}" "${cross_${config_type}_log}")
endfunction()


function(vcpkg_configure_meson)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "NO_PKG_CONFIG"
        "SOURCE_PATH"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;ADDITIONAL_NATIVE_BINARIES;ADDITIONAL_CROSS_BINARIES"
    )

    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    z_vcpkg_get_cmake_vars(cmake_vars_file)
    debug_message("Including cmake vars from: ${cmake_vars_file}")
    include("${cmake_vars_file}")

    vcpkg_find_acquire_program(MESON)

    vcpkg_list(APPEND arg_OPTIONS --buildtype plain --backend ninja --wrap-mode nodownload)

    # Allow overrides / additional configuration variables from triplets
    if(DEFINED VCPKG_MESON_CONFIGURE_OPTIONS)
        vcpkg_list(APPEND arg_OPTIONS ${VCPKG_MESON_CONFIGURE_OPTIONS})
    endif()
    if(DEFINED VCPKG_MESON_CONFIGURE_OPTIONS_RELEASE)
        vcpkg_list(APPEND arg_OPTIONS_RELEASE ${VCPKG_MESON_CONFIGURE_OPTIONS_RELEASE})
    endif()
    if(DEFINED VCPKG_MESON_CONFIGURE_OPTIONS_DEBUG)
        vcpkg_list(APPEND arg_OPTIONS_DEBUG ${VCPKG_MESON_CONFIGURE_OPTIONS_DEBUG})
    endif()

    if(NOT vcpkg_meson_cross_file)
        z_vcpkg_meson_generate_cross_file("${arg_ADDITIONAL_CROSS_BINARIES}")
    endif()
    # We must use uppercase `DEBUG` and `RELEASE` here because they matches the configuration data
    if(NOT VCPKG_MESON_CROSS_FILE_DEBUG AND vcpkg_meson_cross_file)
        z_vcpkg_meson_generate_cross_file_config(DEBUG)
    endif()
    if(NOT VCPKG_MESON_CROSS_FILE_RELEASE AND vcpkg_meson_cross_file)
        z_vcpkg_meson_generate_cross_file_config(RELEASE)
    endif()
    if(vcpkg_meson_cross_file)
        vcpkg_list(APPEND arg_OPTIONS --cross "${vcpkg_meson_cross_file}")
    endif()
    if(VCPKG_MESON_CROSS_FILE_DEBUG)
        vcpkg_list(APPEND arg_OPTIONS_DEBUG --cross "${VCPKG_MESON_CROSS_FILE_DEBUG}")
    endif()
    if(VCPKG_MESON_CROSS_FILE_RELEASE)
        vcpkg_list(APPEND arg_OPTIONS_RELEASE --cross "${VCPKG_MESON_CROSS_FILE_RELEASE}")
    endif()

    if(NOT vcpkg_meson_native_file AND NOT vcpkg_meson_cross_file)
        z_vcpkg_meson_generate_native_file("${arg_ADDITIONAL_NATIVE_BINARIES}")
    endif()
    if(NOT vcpkg_meson_native_file_DEBUG AND NOT vcpkg_meson_cross_file)
        z_vcpkg_meson_generate_native_file_config(DEBUG)
    endif()
    if(NOT vcpkg_meson_native_file_RELEASE AND NOT vcpkg_meson_cross_file)
        z_vcpkg_meson_generate_native_file_config(RELEASE)
    endif()
    if(vcpkg_meson_native_file AND NOT vcpkg_meson_cross_file)
        vcpkg_list(APPEND arg_OPTIONS --native "${vcpkg_meson_native_file}")
        vcpkg_list(APPEND arg_OPTIONS_DEBUG --native "${vcpkg_meson_native_file_DEBUG}")
        vcpkg_list(APPEND arg_OPTIONS_RELEASE --native "${vcpkg_meson_native_file_RELEASE}")
    else()
        vcpkg_list(APPEND arg_OPTIONS --native "${SCRIPTS}/buildsystems/meson/none.txt")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_list(APPEND arg_OPTIONS --default-library shared)
    else()
        vcpkg_list(APPEND arg_OPTIONS --default-library static)
    endif()

    vcpkg_list(APPEND arg_OPTIONS --libdir lib) # else meson install into an architecture describing folder
    vcpkg_list(APPEND arg_OPTIONS_DEBUG -Ddebug=true --prefix "${CURRENT_PACKAGES_DIR}/debug" --includedir ../include)
    vcpkg_list(APPEND arg_OPTIONS_RELEASE -Ddebug=false --prefix "${CURRENT_PACKAGES_DIR}")

    # select meson cmd-line options
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_list(APPEND arg_OPTIONS_DEBUG "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/share']")
        vcpkg_list(APPEND arg_OPTIONS_RELEASE "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}/share']")
    else()
        vcpkg_list(APPEND arg_OPTIONS_DEBUG "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}']")
        vcpkg_list(APPEND arg_OPTIONS_RELEASE "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/debug']")
    endif()
    
    set(buildtypes)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(buildname "DEBUG")
        vcpkg_list(APPEND buildtypes ${buildname})
        set(path_suffix_${buildname} "debug/")
        set(suffix_${buildname} "dbg")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(buildname "RELEASE")
        vcpkg_list(APPEND buildtypes ${buildname})
        set(path_suffix_${buildname} "")
        set(suffix_${buildname} "rel")
    endif()

    vcpkg_backup_env_variables(VARS INCLUDE)
    vcpkg_host_path_list(APPEND ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include")
    # configure build
    foreach(buildtype IN LISTS buildtypes)
        message(STATUS "Configuring ${TARGET_TRIPLET}-${suffix_${buildtype}}")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}")
        #setting up PKGCONFIG
        if(NOT arg_NO_PKG_CONFIG)
            if ("${buildtype}" STREQUAL "DEBUG")
                z_vcpkg_setup_pkgconfig_path(BASE_DIRS "${CURRENT_INSTALLED_DIR}/debug")
            else()
                z_vcpkg_setup_pkgconfig_path(BASE_DIRS "${CURRENT_INSTALLED_DIR}")
            endif()
        endif()

        vcpkg_execute_required_process(
            COMMAND ${MESON} ${arg_OPTIONS} ${arg_OPTIONS_${buildtype}} ${arg_SOURCE_PATH}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}"
            LOGNAME config-${TARGET_TRIPLET}-${suffix_${buildtype}}
            SAVE_LOG_FILES
                meson-logs/meson-log.txt
                meson-info/intro-dependencies.json
                meson-logs/install-log.txt
        )

        message(STATUS "Configuring ${TARGET_TRIPLET}-${suffix_${buildtype}} done")

        if(NOT arg_NO_PKG_CONFIG)
            z_vcpkg_restore_pkgconfig_path()
        endif()
    endforeach()

    vcpkg_restore_env_variables(VARS INCLUDE)
endfunction()
