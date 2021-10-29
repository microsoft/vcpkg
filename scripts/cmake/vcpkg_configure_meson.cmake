#[===[.md:
# vcpkg_configure_meson

Configure Meson for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_configure_meson(
    SOURCE_PATH <${SOURCE_PATH}>
    [NO_PKG_CONFIG]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the `meson.build`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### OPTIONS
Additional options passed to Meson during the configuration.

### OPTIONS_RELEASE
Additional options passed to Meson during the Release configuration. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to Meson during the Debug configuration. These are in addition to `OPTIONS`.

### NO_PKG_CONFIG
Disable pkg-config setup 

## Notes
This command supplies many common arguments to Meson. To see the full list, examine the source.

## Examples

* [fribidi](https://github.com/Microsoft/vcpkg/blob/master/ports/fribidi/portfile.cmake)
* [libepoxy](https://github.com/Microsoft/vcpkg/blob/master/ports/libepoxy/portfile.cmake)
#]===]

function(z_vcpkg_internal_meson_generate_native_file additional_binaries) #https://mesonbuild.com/Native-environments.html
    set(native_config "[binaries]\n")
    #set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(proglist MT)
    else()
        set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    endif()
    foreach(prog IN LISTS proglist)
        if(VCPKG_DETECTED_CMAKE_${prog})
            string(TOLOWER "${prog}" proglower)
            string(APPEND native_config "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}}'\n")
        endif()
    endforeach()
    set(programs C CXX RC)
    foreach(prog IN LISTS programs)
        if(VCPKG_DETECTED_CMAKE_${prog}_COMPILER)
            string(REPLACE "CXX" "CPP" mesonprog "${prog}")
            string(REPLACE "RC" "windres" mesonprog "${mesonprog}") # https://mesonbuild.com/Windows-module.html
            string(TOLOWER "${mesonprog}" proglower)
            string(APPEND native_config "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}_COMPILER}'\n")
        endif()
    endforeach()
    if(VCPKG_DETECTED_CMAKE_LINKER AND VCPKG_TARGET_IS_WINDOWS)
        if (NOT VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "^(GNU|Intel)$") # for gcc and icc the linker flag -fuse-ld is used. See https://github.com/mesonbuild/meson/issues/8647#issuecomment-878673456
            string(APPEND native_config "c_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
        endif()
    endif()
    if(VCPKG_DETECTED_CMAKE_LINKER AND VCPKG_TARGET_IS_WINDOWS)
        if (NOT VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "^(GNU|Intel)$") # for gcc and icc the linker flag -fuse-ld is used. See https://github.com/mesonbuild/meson/issues/8647#issuecomment-878673456
            string(APPEND native_config "cpp_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
        endif()
    endif()
    string(APPEND native_config "cmake = '${CMAKE_COMMAND}'\n")
    foreach(additional_binary IN LISTS additional_binaries)
        string(APPEND native_config "${additional_binary}\n")
    endforeach()

    string(APPEND native_config "[built-in options]\n") #https://mesonbuild.com/Builtin-options.html
    if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe")
        # This is currently wrongly documented in the meson docs or buggy. The docs say: 'none' = no flags
        # In reality however 'none' tries to deactivate eh and meson passes the flags for it resulting in a lot of warnings
        # about overriden flags. Until this is fixed in meson vcpkg should not pass this here.
        # string(APPEND native_config "cpp_eh='none'\n") # To make sure meson is not adding eh flags by itself using msvc
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        string(REGEX REPLACE "( |^)(-|/)" ";\\2" win_c_standard_libraries "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES}")
        string(REGEX REPLACE "\\.lib " ".lib;" win_c_standard_libraries "${win_c_standard_libraries}")
        list(TRANSFORM win_c_standard_libraries APPEND "'")
        list(TRANSFORM win_c_standard_libraries PREPEND "'")
        vcpkg_list(REMOVE_ITEM win_c_standard_libraries "''")
        vcpkg_list(JOIN win_c_standard_libraries ", " win_c_standard_libraries)
        string(APPEND native_config "c_winlibs = [${win_c_standard_libraries}]\n")
        string(REGEX REPLACE "( |^)(-|/)" ";\\2" WIN_CXX_STANDARD_LIBRARIES "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        string(REGEX REPLACE "\\.lib " ".lib;" WIN_CXX_STANDARD_LIBRARIES "${WIN_CXX_STANDARD_LIBRARIES}")
        list(TRANSFORM WIN_CXX_STANDARD_LIBRARIES APPEND "'")
        list(TRANSFORM WIN_CXX_STANDARD_LIBRARIES PREPEND "'")
        vcpkg_list(REMOVE_ITEM WIN_CXX_STANDARD_LIBRARIES "''")
        vcpkg_list(JOIN WIN_CXX_STANDARD_LIBRARIES ", " WIN_CXX_STANDARD_LIBRARIES)
        string(APPEND native_config "cpp_winlibs = [${WIN_CXX_STANDARD_LIBRARIES}]\n")
    endif()

    set(native_config_name "${CURRENT_BUILDTREES_DIR}/meson-nativ-${TARGET_TRIPLET}.log")
    set(VCPKG_MESON_NATIVE_FILE "${native_config_name}" PARENT_SCOPE)
    file(WRITE "${native_config_name}" "${native_config}")
endfunction()

function(z_vcpkg_internal_meson_convert_compiler_flags_to_list out_var _compiler_flags)
    string(REPLACE ";" "\\\;" tmp_var "${_compiler_flags}")
    string(REGEX REPLACE [=[( +|^)((\"(\\\"|[^"])+\"|\\\"|\\ |[^ ])+)]=] ";\\2" ${out_var} "${tmp_var}")
    vcpkg_list(POP_FRONT ${out_var}) # The first element is always empty due to the above replacement
    list(TRANSFORM ${out_var} STRIP) # Strip leading trailing whitespaces from each element in the list.
    set(${out_var} "${${out_var}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_internal_meson_convert_list_to_python_array out_var)
    set(flag_list ${ARGN})
    list(TRANSFORM flag_list APPEND "'")
    list(TRANSFORM flag_list PREPEND "'")
    vcpkg_list(JOIN flag_list ", " ${out_var})
    string(REPLACE "'', " "" ${out_var} "${${out_var}}") # remove empty elements if any
    set(${out_var} "[${${out_var}}]" PARENT_SCOPE)
endfunction()

# Generates the required compiler properties for meson
function(z_vcpkg_internal_meson_generate_flags_properties_string out_var config_type)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        set(L_FLAG /LIBPATH:)
    else()
        set(L_FLAG -L)
    endif()
    set(PATH_SUFFIX_DEBUG /debug)
    set(LIBPATH_${config_type} "${L_FLAG}${CURRENT_INSTALLED_DIR}${path_suffix_${config_type}}/lib")
    z_vcpkg_internal_meson_convert_compiler_flags_to_list(MESON_CFLAGS_${config_type} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${config_type}}")
    vcpkg_list(APPEND MESON_CFLAGS_${config_type} "-I${CURRENT_INSTALLED_DIR}/include")
    z_vcpkg_internal_meson_convert_list_to_python_array(MESON_CFLAGS_${config_type} ${MESON_CFLAGS_${config_type}})
    string(APPEND ${out_var} "c_args = ${MESON_CFLAGS_${config_type}}\n")
    z_vcpkg_internal_meson_convert_compiler_flags_to_list(MESON_CXXFLAGS_${config_type} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${config_type}}")
    vcpkg_list(APPEND MESON_CXXFLAGS_${config_type} "-I${CURRENT_INSTALLED_DIR}/include")
    z_vcpkg_internal_meson_convert_list_to_python_array(MESON_CXXFLAGS_${config_type} ${MESON_CXXFLAGS_${config_type}})
    string(APPEND ${out_var} "cpp_args = ${MESON_CXXFLAGS_${config_type}}\n")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(LINKER_FLAGS_${config_type} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${config_type}}")
    else()
        set(LINKER_FLAGS_${config_type} "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${config_type}}")
    endif()
    z_vcpkg_internal_meson_convert_compiler_flags_to_list(LINKER_FLAGS_${config_type} "${LINKER_FLAGS_${config_type}}")
    vcpkg_list(APPEND LINKER_FLAGS_${config_type} "${LIBPATH_${config_type}}")
    z_vcpkg_internal_meson_convert_list_to_python_array(LINKER_FLAGS_${config_type} ${LINKER_FLAGS_${config_type}})
    string(APPEND ${out_var} "c_link_args = ${LINKER_FLAGS_${config_type}}\n")
    string(APPEND ${out_var} "cpp_link_args = ${LINKER_FLAGS_${config_type}}\n")
    set(${out_var} "${${out_var}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_internal_meson_generate_native_file_config config_type) #https://mesonbuild.com/Native-environments.html
    set(native_${config_type} "[properties]\n") #https://mesonbuild.com/Builtin-options.html
    z_vcpkg_internal_meson_generate_flags_properties_string(native_properties ${config_type})
    string(APPEND native_${config_type} "${native_properties}")
    #Setup CMake properties
    string(APPEND native_${config_type} "cmake_toolchain_file  = '${SCRIPTS}/buildsystems/vcpkg.cmake'\n")
    string(APPEND native_${config_type} "[cmake]\n")

    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        elseif(VCPKG_TARGET_IS_LINUX)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
        elseif(VCPKG_TARGET_IS_ANDROID)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
        elseif(VCPKG_TARGET_IS_OSX)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
        elseif(VCPKG_TARGET_IS_IOS)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/ios.cmake")
        elseif(VCPKG_TARGET_IS_FREEBSD)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/freebsd.cmake")
        elseif(VCPKG_TARGET_IS_OPENBSD)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/openbsd.cmake")
        elseif(VCPKG_TARGET_IS_MINGW)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake")
        endif()
    endif()

    string(APPEND native_${config_type} "VCPKG_TARGET_TRIPLET = '${TARGET_TRIPLET}'\n")
    string(APPEND native_${config_type} "VCPKG_CHAINLOAD_TOOLCHAIN_FILE = '${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}'\n")
    string(APPEND native_${config_type} "VCPKG_CRT_LINKAGE = '${VCPKG_CRT_LINKAGE}'\n")

    string(APPEND native_${config_type} "[built-in options]\n")
    if(VCPKG_TARGET_IS_WINDOWS)
        if(VCPKG_CRT_LINKAGE STREQUAL "static")
            set(crt_type mt)
        else()
            set(crt_type md)
        endif()
        if(${config_type} STREQUAL "DEBUG")
            set(crt_type ${crt_type}d)
        endif()
        string(APPEND native_${config_type} "b_vscrt = '${crt_type}'\n")
    endif()
    string(TOLOWER "${config_type}" lowerconfig)
    set(native_config_name "${CURRENT_BUILDTREES_DIR}/meson-nativ-${TARGET_TRIPLET}-${lowerconfig}.log")
    set(VCPKG_MESON_NATIVE_FILE_${config_type} "${native_config_name}" PARENT_SCOPE)
    file(WRITE "${native_config_name}" "${native_${config_type}}")
endfunction()

function(vcpkg_internal_meson_generate_cross_file additional_binaries) #https://mesonbuild.com/Cross-compilation.html
    if(CMAKE_HOST_WIN32)
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(BUILD_ARCH $ENV{PROCESSOR_ARCHITEW6432})
        else()
            set(BUILD_ARCH $ENV{PROCESSOR_ARCHITECTURE})
        endif()
        if(BUILD_ARCH MATCHES "(amd|AMD)64")
            set(BUILD_CPU_FAM x86_64)
            set(BUILD_CPU x86_64)
        elseif(BUILD_ARCH MATCHES "(x|X)86")
            set(BUILD_CPU_FAM x86)
            set(BUILD_CPU i686)
        elseif(BUILD_ARCH MATCHES "^(ARM|arm)64$")
            set(BUILD_CPU_FAM aarch64)
            set(BUILD_CPU armv8)
        elseif(BUILD_ARCH MATCHES "^(ARM|arm)$")
            set(BUILD_CPU_FAM arm)
            set(BUILD_CPU armv7hl)
        else()
            message(FATAL_ERROR "Unsupported host architecture ${BUILD_ARCH}!")
        endif()
    elseif(CMAKE_HOST_UNIX)
        # at this stage, CMAKE_HOST_SYSTEM_PROCESSOR is not defined
        execute_process(
            COMMAND "uname -m"
            OUTPUT_VARIABLE MACHINE
            COMMAND_ERROR_IS_FATAL ANY)
        
        # Show real machine architecture to visually understand whether we are in a native Apple Silicon terminal or running under Rosetta emulation
        debug_message("Machine: ${MACHINE}")

        if(MACHINE MATCHES "arm64")
            set(BUILD_CPU_FAM aarch64)
            set(BUILD_CPU armv8)
        elseif(MACHINE MATCHES "x86_64|amd64")
            set(BUILD_CPU_FAM x86_64)
            set(BUILD_CPU x86_64)
        elseif(MACHINE MATCHES "x86|i686")
            set(BUILD_CPU_FAM x86)
            set(BUILD_CPU i686)
        elseif(MACHINE MATCHES "i386")
            set(BUILD_CPU_FAM x86)
            set(BUILD_CPU i386)
        else()
            unset(BUILD_CPU_FAM)
            unset(BUILD_CPU)

            # https://github.com/mesonbuild/meson/blob/master/docs/markdown/Reference-tables.md#cpu-families
            message(FATAL_ERROR "Unhandled machine: ${MACHINE}")
        endif()
    else()
        message(FATAL_ERROR "Failed to detect the host architecture!")
    endif()

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(amd|AMD|x|X)64")
        set(HOST_CPU_FAM x86_64)
        set(HOST_CPU x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)86")
        set(HOST_CPU_FAM x86)
        set(HOST_CPU i686)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)64$")
        set(HOST_CPU_FAM aarch64)
        set(HOST_CPU armv8)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)$")
        set(HOST_CPU_FAM arm)
        set(HOST_CPU armv7hl)
    else()
        message(FATAL_ERROR "Unsupported target architecture ${VCPKG_TARGET_ARCHITECTURE}!" )
    endif()
    set(cross_file "[binaries]\n")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(proglist MT)
    else()
        set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    endif()
    foreach(prog IN LISTS proglist)
        if(VCPKG_DETECTED_CMAKE_${prog})
            string(TOLOWER "${prog}" proglower)
            string(APPEND cross_file "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}}'\n")
        endif()
    endforeach()
    set(programs C CXX RC)
    foreach(prog IN LISTS programs)
        if(VCPKG_DETECTED_CMAKE_${prog}_COMPILER)
            string(REPLACE "CXX" "CPP" mesonprog "${prog}")
            string(REPLACE "RC" "windres" mesonprog "${mesonprog}") # https://mesonbuild.com/Windows-module.html
            string(TOLOWER "${mesonprog}" proglower)
            string(APPEND cross_file "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}_COMPILER}'\n")
        endif()
    endforeach()
    if(VCPKG_DETECTED_CMAKE_LINKER AND VCPKG_TARGET_IS_WINDOWS)
        if (NOT VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "^(GNU|Intel)$") # for gcc and icc the linker flag -fuse-ld is used. See https://github.com/mesonbuild/meson/issues/8647#issuecomment-878673456
            string(APPEND cross_file "c_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
        endif()
    endif()
    if(VCPKG_DETECTED_CMAKE_LINKER AND VCPKG_TARGET_IS_WINDOWS)
        if (NOT VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "^(GNU|Intel)$") # for gcc and icc the linker flag -fuse-ld is used. See https://github.com/mesonbuild/meson/issues/8647#issuecomment-878673456
            string(APPEND cross_file "cpp_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
        endif()
    endif()
    string(APPEND cross_file "cmake = '${CMAKE_COMMAND}'\n")
    foreach(additional_binary IN LISTS additional_binaries)
        string(APPEND cross_file "${additional_binary}\n")
    endforeach()

    string(APPEND cross_file "[properties]\n")

    string(APPEND cross_file "[host_machine]\n")
    string(APPEND cross_file "endian = 'little'\n")
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_TARGET_IS_MINGW)
        set(meson_system_name "windows")
    else()
        string(TOLOWER "${VCPKG_CMAKE_SYSTEM_NAME}" meson_system_name)
    endif()
    string(APPEND cross_file "system = '${meson_system_name}'\n")
    string(APPEND cross_file "cpu_family = '${HOST_CPU_FAM}'\n")
    string(APPEND cross_file "cpu = '${HOST_CPU}'\n")

    string(APPEND cross_file "[build_machine]\n")
    string(APPEND cross_file "endian = 'little'\n")
    if(WIN32)
        string(APPEND cross_file "system = 'windows'\n")
    elseif(DARWIN)
        string(APPEND cross_file "system = 'darwin'\n")
    else()
        string(APPEND cross_file "system = 'linux'\n")
    endif()

    if(DEFINED BUILD_CPU_FAM)
        string(APPEND cross_file "cpu_family = '${BUILD_CPU_FAM}'\n")
    endif()
    if(DEFINED BUILD_CPU)
        string(APPEND cross_file "cpu = '${BUILD_CPU}'\n")
    endif()

    if(NOT BUILD_CPU_FAM MATCHES "${HOST_CPU_FAM}" OR VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_UWP OR (VCPKG_TARGET_IS_MINGW AND NOT WIN32))
        set(native_config_name "${CURRENT_BUILDTREES_DIR}/meson-cross-${TARGET_TRIPLET}.log")
        set(VCPKG_MESON_CROSS_FILE "${native_config_name}" PARENT_SCOPE)
        file(WRITE "${native_config_name}" "${cross_file}")
    endif()
endfunction()

function(vcpkg_internal_meson_generate_cross_file_config config_type) #https://mesonbuild.com/Native-environments.html
    set(cross_${config_type}_log "[properties]\n") #https://mesonbuild.com/Builtin-options.html
    z_vcpkg_internal_meson_generate_flags_properties_string(cross_properties ${config_type})
    string(APPEND cross_${config_type}_log "${cross_properties}")
    string(APPEND cross_${config_type}_log "[built-in options]\n")
    if(VCPKG_TARGET_IS_WINDOWS)
        if(VCPKG_CRT_LINKAGE STREQUAL "static")
            set(crt_type mt)
        else()
            set(crt_type md)
        endif()
        if(${config_type} STREQUAL "DEBUG")
            set(crt_type ${crt_type}d)
        endif()
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

    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
    vcpkg_add_to_path("${PYTHON3_DIR}")
    vcpkg_list(APPEND arg_ADDITIONAL_NATIVE_BINARIES "python = '${PYTHON3}'")
    vcpkg_list(APPEND arg_ADDITIONAL_CROSS_BINARIES "python = '${PYTHON3}'")

    vcpkg_find_acquire_program(MESON)

    get_filename_component(CMAKE_PATH ${CMAKE_COMMAND} DIRECTORY)
    vcpkg_add_to_path("${CMAKE_PATH}") # Make CMake invokeable for Meson

    vcpkg_find_acquire_program(NINJA)
    get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${NINJA_PATH}") # Need to prepend so that meson picks up the correct ninja from vcpkg ....
    # vcpkg_list(APPEND arg_ADDITIONAL_NATIVE_BINARIES "ninja = '${NINJA}'") # This does not work due to meson issues ......

    vcpkg_list(APPEND arg_OPTIONS --buildtype plain --backend ninja --wrap-mode nodownload)

    if(NOT VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_cross_file("${arg_ADDITIONAL_CROSS_BINARIES}")
    endif()
    # We must use uppercase `DEBUG` and `RELEASE` here because they matches the configuration data
    if(NOT VCPKG_MESON_CROSS_FILE_DEBUG AND VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_cross_file_config(DEBUG)
    endif()
    if(NOT VCPKG_MESON_CROSS_FILE_RELEASE AND VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_cross_file_config(RELEASE)
    endif()
    if(VCPKG_MESON_CROSS_FILE)
        vcpkg_list(APPEND arg_OPTIONS --cross "${VCPKG_MESON_CROSS_FILE}")
    endif()
    if(VCPKG_MESON_CROSS_FILE_DEBUG)
        vcpkg_list(APPEND arg_OPTIONS_DEBUG --cross "${VCPKG_MESON_CROSS_FILE_DEBUG}")
    endif()
    if(VCPKG_MESON_CROSS_FILE_RELEASE)
        vcpkg_list(APPEND arg_OPTIONS_RELEASE --cross "${VCPKG_MESON_CROSS_FILE_RELEASE}")
    endif()

    if(NOT VCPKG_MESON_NATIVE_FILE AND NOT VCPKG_MESON_CROSS_FILE)
        z_vcpkg_internal_meson_generate_native_file("${arg_ADDITIONAL_NATIVE_BINARIES}")
    endif()
    if(NOT VCPKG_MESON_NATIVE_FILE_DEBUG AND NOT VCPKG_MESON_CROSS_FILE)
        z_vcpkg_internal_meson_generate_native_file_config(DEBUG)
    endif()
    if(NOT VCPKG_MESON_NATIVE_FILE_RELEASE AND NOT VCPKG_MESON_CROSS_FILE)
        z_vcpkg_internal_meson_generate_native_file_config(RELEASE)
    endif()
    if(VCPKG_MESON_NATIVE_FILE AND NOT VCPKG_MESON_CROSS_FILE)
        vcpkg_list(APPEND arg_OPTIONS --native "${VCPKG_MESON_NATIVE_FILE}")
        vcpkg_list(APPEND arg_OPTIONS_DEBUG --native "${VCPKG_MESON_NATIVE_FILE_DEBUG}")
        vcpkg_list(APPEND arg_OPTIONS_RELEASE --native "${VCPKG_MESON_NATIVE_FILE_RELEASE}")
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
    
    if(NOT arg_NO_PKG_CONFIG)
        vcpkg_find_acquire_program(PKGCONFIG)
        get_filename_component(PKGCONFIG_PATH ${PKGCONFIG} DIRECTORY)
        vcpkg_add_to_path("${PKGCONFIG_PATH}")
        set(pkgconfig_share_dir "${CURRENT_INSTALLED_DIR}/share/pkgconfig/")
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

    if(VCPKG_TARGET_IS_OSX)
        vcpkg_backup_env_variables(VARS SDKROOT MACOSX_DEPLOYMENT_TARGET)

        set(ENV{SDKROOT} "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
        set(VCPKG_DETECTED_CMAKE_OSX_SYSROOT "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}" PARENT_SCOPE)

        set(ENV{MACOSX_DEPLOYMENT_TARGET} "${VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET}")
        set(VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET "${VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET}" PARENT_SCOPE)
    endif()

    vcpkg_backup_env_variables(VARS INCLUDE)
    vcpkg_host_path_list(APPEND ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include")
    # configure build
    foreach(buildtype IN LISTS buildtypes)
        message(STATUS "Configuring ${TARGET_TRIPLET}-${suffix_${buildtype}}")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}")
        #setting up PKGCONFIG
        vcpkg_backup_env_variables(VARS PKG_CONFIG PKG_CONFIG_PATH)
        if(NOT arg_NO_PKG_CONFIG)
            set(ENV{PKG_CONFIG} "${PKGCONFIG}") # Set via native file?
            set(pkgconfig_installed_dir "${CURRENT_INSTALLED_DIR}/${path_suffix_${buildtype}}lib/pkgconfig/")
            vcpkg_host_path_list(APPEND ENV{PKG_CONFIG_PATH} "${pkgconfig_share_dir}" "$ENV{PKG_CONFIG_PATH}")
        endif()

        vcpkg_execute_required_process(
            COMMAND ${MESON} ${arg_OPTIONS} ${arg_OPTIONS_${buildtype}} ${arg_SOURCE_PATH}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}"
            LOGNAME config-${TARGET_TRIPLET}-${suffix_${buildtype}}
        )

        #Copy meson log files into buildtree for CI
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}/meson-logs/meson-log.txt")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}/meson-logs/meson-log.txt" DESTINATION "${CURRENT_BUILDTREES_DIR}")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/meson-log.txt" "${CURRENT_BUILDTREES_DIR}/meson-log-${suffix_${buildtype}}.txt")
        endif()
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}/meson-logs/install-log.txt")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${suffix_${buildtype}}/meson-logs/install-log.txt" DESTINATION "${CURRENT_BUILDTREES_DIR}")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/install-log.txt" "${CURRENT_BUILDTREES_DIR}/install-log-${suffix_${buildtype}}.txt")
        endif()
        message(STATUS "Configuring ${TARGET_TRIPLET}-${suffix_${buildtype}} done")

        vcpkg_restore_env_variables(VARS PKG_CONFIG PKG_CONFIG_PATH)
    endforeach()

    if(VCPKG_TARGET_IS_OSX)
        vcpkg_restore_env_variables(VARS SDKROOT MACOSX_DEPLOYMENT_TARGET)
    endif()
    vcpkg_restore_env_variables(VARS INCLUDE)
endfunction()
