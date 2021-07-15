#[===[.md:
# vcpkg_configure_meson

Configure Meson for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_configure_meson(
    SOURCE_PATH <${SOURCE_PATH}>
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

## Notes
This command supplies many common arguments to Meson. To see the full list, examine the source.

## Examples

* [fribidi](https://github.com/Microsoft/vcpkg/blob/master/ports/fribidi/portfile.cmake)
* [libepoxy](https://github.com/Microsoft/vcpkg/blob/master/ports/libepoxy/portfile.cmake)
#]===]

function(vcpkg_internal_meson_generate_native_file _additional_binaries) #https://mesonbuild.com/Native-environments.html
    set(NATIVE "[binaries]\n")
    #set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(proglist MT)
    else()
        set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    endif()
    foreach(prog IN LISTS proglist)
        if(VCPKG_DETECTED_CMAKE_${prog})
            string(TOLOWER "${prog}" proglower)
            string(APPEND NATIVE "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}}'\n")
        endif()
    endforeach()
    set(compiler C CXX RC)
    foreach(prog IN LISTS compiler)
        if(VCPKG_DETECTED_CMAKE_${prog}_COMPILER)
            string(REPLACE "CXX" "CPP" mesonprog "${prog}")
            string(TOLOWER "${mesonprog}" proglower)
            string(APPEND NATIVE "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}_COMPILER}'\n")
        endif()
    endforeach()
    if(VCPKG_DETECTED_CMAKE_LINKER AND VCPKG_TARGET_IS_WINDOWS)
        string(APPEND NATIVE "c_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
        string(APPEND NATIVE "cpp_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
    endif()
    string(APPEND NATIVE "cmake = '${CMAKE_COMMAND}'\n")
    foreach(_binary IN LISTS ${_additional_binaries})
        string(APPEND NATIVE "${_binary}\n")
    endforeach()

    string(APPEND NATIVE "[built-in options]\n") #https://mesonbuild.com/Builtin-options.html
    if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe")
        # This is currently wrongly documented in the meson docs or buggy. The docs say: 'none' = no flags
        # In reality however 'none' tries to deactivate eh and meson passes the flags for it resulting in a lot of warnings
        # about overriden flags. Until this is fixed in meson vcpkg should not pass this here.
        # string(APPEND NATIVE "cpp_eh='none'\n") # To make sure meson is not adding eh flags by itself using msvc
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        string(REGEX REPLACE "( |^)(-|/)" ";\\2" WIN_C_STANDARD_LIBRARIES "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES}")
        string(REGEX REPLACE "\\.lib " ".lib;" WIN_C_STANDARD_LIBRARIES "${WIN_C_STANDARD_LIBRARIES}")
        list(TRANSFORM WIN_C_STANDARD_LIBRARIES APPEND "'")
        list(TRANSFORM WIN_C_STANDARD_LIBRARIES PREPEND "'")
        list(JOIN WIN_C_STANDARD_LIBRARIES ", " WIN_C_STANDARD_LIBRARIES)
        string(APPEND NATIVE "c_winlibs = [${WIN_C_STANDARD_LIBRARIES}]\n")
        string(REGEX REPLACE "( |^)(-|/)" ";\\2" WIN_CXX_STANDARD_LIBRARIES "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        string(REGEX REPLACE "\\.lib " ".lib;" WIN_CXX_STANDARD_LIBRARIES "${WIN_CXX_STANDARD_LIBRARIES}")
        list(TRANSFORM WIN_CXX_STANDARD_LIBRARIES APPEND "'")
        list(TRANSFORM WIN_CXX_STANDARD_LIBRARIES PREPEND "'")
        list(JOIN WIN_CXX_STANDARD_LIBRARIES ", " WIN_CXX_STANDARD_LIBRARIES)
        string(APPEND NATIVE "cpp_winlibs = [${WIN_CXX_STANDARD_LIBRARIES}]\n")
    endif()

    set(_file "${CURRENT_BUILDTREES_DIR}/meson-nativ-${TARGET_TRIPLET}.log")
    set(VCPKG_MESON_NATIVE_FILE "${_file}" PARENT_SCOPE)
    file(WRITE "${_file}" "${NATIVE}")
endfunction()

function(vcpkg_internal_meson_convert_compiler_flags_to_list _out_var _compiler_flags)
    string(REPLACE ";" "\\\;" tmp_var "${_compiler_flags}")
    string(REGEX REPLACE [=[( +|^)((\"(\\\"|[^"])+\"|\\\"|\\ |[^ ])+)]=] ";\\2" ${_out_var} "${tmp_var}")
    list(POP_FRONT ${_out_var}) # The first element is always empty due to the above replacement
    list(TRANSFORM ${_out_var} STRIP) # Strip leading trailing whitespaces from each element in the list.
    set(${_out_var} "${${_out_var}}" PARENT_SCOPE)
endfunction()

function(vcpkg_internal_meson_convert_list_to_python_array _out_var)
    set(FLAG_LIST ${ARGN})
    list(TRANSFORM FLAG_LIST APPEND "'")
    list(TRANSFORM FLAG_LIST PREPEND "'")
    list(JOIN FLAG_LIST ", " ${_out_var})
    string(REPLACE "'', " "" ${_out_var} "${${_out_var}}") # remove empty elements if any
    set(${_out_var} "[${${_out_var}}]" PARENT_SCOPE)
endfunction()

# Generates the required compiler properties for meson
function(vcpkg_internal_meson_generate_flags_properties_string _out_var _config)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        set(L_FLAG /LIBPATH:)
    else()
        set(L_FLAG -L)
    endif()
    set(PATH_SUFFIX_DEBUG /debug)
    set(LIBPATH_${_config} "${L_FLAG}${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_config}}/lib")
    vcpkg_internal_meson_convert_compiler_flags_to_list(MESON_CFLAGS_${_config} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${_config}}")
    list(APPEND MESON_CFLAGS_${_config} "-I\"${CURRENT_INSTALLED_DIR}/include\"")
    vcpkg_internal_meson_convert_list_to_python_array(MESON_CFLAGS_${_config} ${MESON_CFLAGS_${_config}})
    string(APPEND ${_out_var} "c_args = ${MESON_CFLAGS_${_config}}\n")
    vcpkg_internal_meson_convert_compiler_flags_to_list(MESON_CXXFLAGS_${_config} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${_config}}")
    list(APPEND MESON_CXXFLAGS_${_config} "-I\"${CURRENT_INSTALLED_DIR}/include\"")
    vcpkg_internal_meson_convert_list_to_python_array(MESON_CXXFLAGS_${_config} ${MESON_CXXFLAGS_${_config}})
    string(APPEND ${_out_var} "cpp_args = ${MESON_CXXFLAGS_${_config}}\n")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(LINKER_FLAGS_${_config} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${_config}}")
    else()
        set(LINKER_FLAGS_${_config} "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${_config}}")
    endif()
    vcpkg_internal_meson_convert_compiler_flags_to_list(LINKER_FLAGS_${_config} "${LINKER_FLAGS_${_config}}")
    list(APPEND LINKER_FLAGS_${_config} "${LIBPATH_${_config}}")
    vcpkg_internal_meson_convert_list_to_python_array(LINKER_FLAGS_${_config} ${LINKER_FLAGS_${_config}})
    string(APPEND ${_out_var} "c_link_args = ${LINKER_FLAGS_${_config}}\n")
    string(APPEND ${_out_var} "cpp_link_args = ${LINKER_FLAGS_${_config}}\n")
    set(${_out_var} "${${_out_var}}" PARENT_SCOPE)
endfunction()

function(vcpkg_internal_meson_generate_native_file_config _config) #https://mesonbuild.com/Native-environments.html
    set(NATIVE_${_config} "[properties]\n") #https://mesonbuild.com/Builtin-options.html
    vcpkg_internal_meson_generate_flags_properties_string(NATIVE_PROPERTIES ${_config})
    string(APPEND NATIVE_${_config} "${NATIVE_PROPERTIES}")
    #Setup CMake properties
    string(APPEND NATIVE_${_config} "cmake_toolchain_file  = '${SCRIPTS}/buildsystems/vcpkg.cmake'\n")
    string(APPEND NATIVE_${_config} "[cmake]\n")

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

    string(APPEND NATIVE_${_config} "VCPKG_TARGET_TRIPLET = '${TARGET_TRIPLET}'\n")
    string(APPEND NATIVE_${_config} "VCPKG_CHAINLOAD_TOOLCHAIN_FILE = '${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}'\n")
    string(APPEND NATIVE_${_config} "VCPKG_CRT_LINKAGE = '${VCPKG_CRT_LINKAGE}'\n")

    string(APPEND NATIVE_${_config} "[built-in options]\n")
    if(VCPKG_TARGET_IS_WINDOWS)
        if(VCPKG_CRT_LINKAGE STREQUAL "static")
            set(CRT mt)
        else()
            set(CRT md)
        endif()
        if(${_config} STREQUAL DEBUG)
            set(CRT ${CRT}d)
        endif()
        string(APPEND NATIVE_${_config} "b_vscrt = '${CRT}'\n")
    endif()
    string(TOLOWER "${_config}" lowerconfig)
    set(_file "${CURRENT_BUILDTREES_DIR}/meson-nativ-${TARGET_TRIPLET}-${lowerconfig}.log")
    set(VCPKG_MESON_NATIVE_FILE_${_config} "${_file}" PARENT_SCOPE)
    file(WRITE "${_file}" "${NATIVE_${_config}}")
endfunction()

function(vcpkg_internal_meson_generate_cross_file _additional_binaries) #https://mesonbuild.com/Cross-compilation.html
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
            COMMAND uname -m
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
    set(CROSS "[binaries]\n")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(proglist MT)
    else()
        set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    endif()
    foreach(prog IN LISTS proglist)
        if(VCPKG_DETECTED_CMAKE_${prog})
            string(TOLOWER "${prog}" proglower)
            string(APPEND CROSS "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}}'\n")
        endif()
    endforeach()
    set(compiler C CXX RC)
    foreach(prog IN LISTS compiler)
        if(VCPKG_DETECTED_CMAKE_${prog}_COMPILER)
            string(REPLACE "CXX" "CPP" mesonprog "${prog}")
            string(TOLOWER "${mesonprog}" proglower)
            string(APPEND CROSS "${proglower} = '${VCPKG_DETECTED_CMAKE_${prog}_COMPILER}'\n")
        endif()
    endforeach()
    if(VCPKG_DETECTED_CMAKE_LINKER AND VCPKG_TARGET_IS_WINDOWS)
        string(APPEND CROSS "c_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
        string(APPEND CROSS "cpp_ld = '${VCPKG_DETECTED_CMAKE_LINKER}'\n")
    endif()
    foreach(_binary IN LISTS ${_additional_binaries})
        string(APPEND CROSS "${_binary}\n")
    endforeach()

    string(APPEND CROSS "[properties]\n")

    string(APPEND CROSS "[host_machine]\n")
    string(APPEND CROSS "endian = 'little'\n")
    if(NOT VCPKG_CMAKE_SYSTEM_NAME)
        set(MESON_SYSTEM_NAME "windows")
    else()
        string(TOLOWER "${VCPKG_CMAKE_SYSTEM_NAME}" MESON_SYSTEM_NAME)
    endif()
    string(APPEND CROSS "system = '${MESON_SYSTEM_NAME}'\n")
    string(APPEND CROSS "cpu_family = '${HOST_CPU_FAM}'\n")
    string(APPEND CROSS "cpu = '${HOST_CPU}'\n")

    string(APPEND CROSS "[build_machine]\n")
    string(APPEND CROSS "endian = 'little'\n")
    if(WIN32)
        string(APPEND CROSS "system = 'windows'\n")
    elseif(DARWIN)
        string(APPEND CROSS "system = 'darwin'\n")
    else()
        string(APPEND CROSS "system = 'linux'\n")
    endif()

    if(DEFINED BUILD_CPU_FAM)
        string(APPEND CROSS "cpu_family = '${BUILD_CPU_FAM}'\n")
    endif()
    if(DEFINED BUILD_CPU)
        string(APPEND CROSS "cpu = '${BUILD_CPU}'\n")
    endif()

    if(NOT BUILD_CPU_FAM MATCHES "${HOST_CPU_FAM}" OR VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_UWP)
        set(_file "${CURRENT_BUILDTREES_DIR}/meson-cross-${TARGET_TRIPLET}.log")
        set(VCPKG_MESON_CROSS_FILE "${_file}" PARENT_SCOPE)
        file(WRITE "${_file}" "${CROSS}")
    endif()
endfunction()

function(vcpkg_internal_meson_generate_cross_file_config _config) #https://mesonbuild.com/Native-environments.html
    set(CROSS_${_config} "[properties]\n") #https://mesonbuild.com/Builtin-options.html
    vcpkg_internal_meson_generate_flags_properties_string(CROSS_PROPERTIES ${_config})
    string(APPEND CROSS_${_config} "${CROSS_PROPERTIES}")
    string(APPEND CROSS_${_config} "[built-in options]\n")
    if(VCPKG_TARGET_IS_WINDOWS)
        if(VCPKG_CRT_LINKAGE STREQUAL "static")
            set(CRT mt)
        else()
            set(CRT md)
        endif()
        if(${_config} STREQUAL DEBUG)
            set(CRT ${CRT}d)
        endif()
        string(APPEND CROSS_${_config} "b_vscrt = '${CRT}'\n")
    endif()
    string(TOLOWER "${_config}" lowerconfig)
    set(_file "${CURRENT_BUILDTREES_DIR}/meson-cross-${TARGET_TRIPLET}-${lowerconfig}.log")
    set(VCPKG_MESON_CROSS_FILE_${_config} "${_file}" PARENT_SCOPE)
    file(WRITE "${_file}" "${CROSS_${_config}}")
endfunction()


function(vcpkg_configure_meson)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _vcm "" "SOURCE_PATH" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;ADDITIONAL_NATIVE_BINARIES;ADDITIONAL_CROSS_BINARIES")

    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    vcpkg_internal_get_cmake_vars(OUTPUT_FILE _VCPKG_CMAKE_VARS_FILE)
    set(_VCPKG_CMAKE_VARS_FILE "${_VCPKG_CMAKE_VARS_FILE}" PARENT_SCOPE)
    debug_message("Including cmake vars from: ${_VCPKG_CMAKE_VARS_FILE}")
    include("${_VCPKG_CMAKE_VARS_FILE}")

    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
    vcpkg_add_to_path("${PYTHON3_DIR}")
    list(APPEND _vcm_ADDITIONAL_NATIVE_BINARIES "python = '${PYTHON3}'")
    list(APPEND _vcm_ADDITIONAL_CROSS_BINARIES "python = '${PYTHON3}'")

    vcpkg_find_acquire_program(MESON)

    get_filename_component(CMAKE_PATH ${CMAKE_COMMAND} DIRECTORY)
    vcpkg_add_to_path("${CMAKE_PATH}") # Make CMake invokeable for Meson

    vcpkg_find_acquire_program(NINJA)
    get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${NINJA_PATH}") # Need to prepend so that meson picks up the correct ninja from vcpkg ....
    # list(APPEND _vcm_ADDITIONAL_NATIVE_BINARIES "ninja = '${NINJA}'") # This does not work due to meson issues ......

    list(APPEND _vcm_OPTIONS --buildtype plain --backend ninja --wrap-mode nodownload)

    if(NOT VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_cross_file("_vcm_ADDITIONAL_CROSS_BINARIES")
    endif()
    if(NOT VCPKG_MESON_CROSS_FILE_DEBUG AND VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_cross_file_config(DEBUG)
    endif()
    if(NOT VCPKG_MESON_CROSS_FILE_RELEASE AND VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_cross_file_config(RELEASE)
    endif()
    if(VCPKG_MESON_CROSS_FILE)
        list(APPEND _vcm_OPTIONS --cross "${VCPKG_MESON_CROSS_FILE}")
    endif()
    if(VCPKG_MESON_CROSS_FILE_DEBUG)
        list(APPEND _vcm_OPTIONS_DEBUG --cross "${VCPKG_MESON_CROSS_FILE_DEBUG}")
    endif()
    if(VCPKG_MESON_CROSS_FILE_RELEASE)
        list(APPEND _vcm_OPTIONS_RELEASE --cross "${VCPKG_MESON_CROSS_FILE_RELEASE}")
    endif()

    if(NOT VCPKG_MESON_NATIVE_FILE AND NOT VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_native_file("_vcm_ADDITIONAL_NATIVE_BINARIES")
    endif()
    if(NOT VCPKG_MESON_NATIVE_FILE_DEBUG AND NOT VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_native_file_config(DEBUG)
    endif()
    if(NOT VCPKG_MESON_NATIVE_FILE_RELEASE AND NOT VCPKG_MESON_CROSS_FILE)
        vcpkg_internal_meson_generate_native_file_config(RELEASE)
    endif()
    if(VCPKG_MESON_NATIVE_FILE AND NOT VCPKG_MESON_CROSS_FILE)
        list(APPEND _vcm_OPTIONS --native "${VCPKG_MESON_NATIVE_FILE}")
        list(APPEND _vcm_OPTIONS_DEBUG --native "${VCPKG_MESON_NATIVE_FILE_DEBUG}")
        list(APPEND _vcm_OPTIONS_RELEASE --native "${VCPKG_MESON_NATIVE_FILE_RELEASE}")
    else()
        list(APPEND _vcm_OPTIONS --native "${SCRIPTS}/buildsystems/meson/none.txt")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND _vcm_OPTIONS --default-library shared)
    else()
        list(APPEND _vcm_OPTIONS --default-library static)
    endif()

    list(APPEND _vcm_OPTIONS --libdir lib) # else meson install into an architecture describing folder
    list(APPEND _vcm_OPTIONS_DEBUG -Ddebug=true --prefix ${CURRENT_PACKAGES_DIR}/debug --includedir ../include)
    list(APPEND _vcm_OPTIONS_RELEASE -Ddebug=false --prefix  ${CURRENT_PACKAGES_DIR})

    # select meson cmd-line options
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND _vcm_OPTIONS_DEBUG "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/share']")
        list(APPEND _vcm_OPTIONS_RELEASE "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}/share']")
    else()
        list(APPEND _vcm_OPTIONS_DEBUG "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}/debug','${CURRENT_INSTALLED_DIR}']")
        list(APPEND _vcm_OPTIONS_RELEASE "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/debug']")
    endif()

    vcpkg_find_acquire_program(PKGCONFIG)
    get_filename_component(PKGCONFIG_PATH ${PKGCONFIG} DIRECTORY)
    vcpkg_add_to_path("${PKGCONFIG_PATH}")
    set(PKGCONFIG_SHARE_DIR "${CURRENT_INSTALLED_DIR}/share/pkgconfig/")

    set(buildtypes)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(BUILDNAME DEBUG)
        list(APPEND buildtypes ${BUILDNAME})
        set(PATH_SUFFIX_${BUILDNAME} "debug/")
        set(SUFFIX_${BUILDNAME} "dbg")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(BUILDNAME RELEASE)
        list(APPEND buildtypes ${BUILDNAME})
        set(PATH_SUFFIX_${BUILDNAME} "")
        set(SUFFIX_${BUILDNAME} "rel")
    endif()

    if(VCPKG_TARGET_IS_OSX)
        if(DEFINED ENV{SDKROOT})
            set(_VCPKG_ENV_SDKROOT_BACKUP $ENV{SDKROOT})
        endif()
        set(ENV{SDKROOT} "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
        set(VCPKG_DETECTED_CMAKE_OSX_SYSROOT "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}" PARENT_SCOPE)

        if(DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
            set(_VCPKG_ENV_MACOSX_DEPLOYMENT_TARGET_BACKUP $ENV{MACOSX_DEPLOYMENT_TARGET})
        endif()
        set(ENV{MACOSX_DEPLOYMENT_TARGET} "${VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET}")
        set(VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET "${VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET}" PARENT_SCOPE)
    endif()

    if(DEFINED ENV{INCLUDE})
        set(ENV{INCLUDE} "$ENV{INCLUDE}${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_INSTALLED_DIR}/include")
    else()
        set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include")
    endif()
    # configure build
    foreach(buildtype IN LISTS buildtypes)
        message(STATUS "Configuring ${TARGET_TRIPLET}-${SUFFIX_${buildtype}}")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SUFFIX_${buildtype}}")
        #setting up PKGCONFIG
        set(ENV{PKG_CONFIG} "${PKGCONFIG}") # Set via native file?
        set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}/${PATH_SUFFIX_${buildtype}}lib/pkgconfig/")
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_RELEASE $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_SHARE_DIR}")
        endif()

        vcpkg_execute_required_process(
            COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_${buildtype}} ${_vcm_SOURCE_PATH}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SUFFIX_${buildtype}}
            LOGNAME config-${TARGET_TRIPLET}-${SUFFIX_${buildtype}}
        )

        #Copy meson log files into buildtree for CI
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SUFFIX_${buildtype}}/meson-logs/meson-log.txt")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SUFFIX_${buildtype}}/meson-logs/meson-log.txt" DESTINATION "${CURRENT_BUILDTREES_DIR}")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/meson-log.txt" "${CURRENT_BUILDTREES_DIR}/meson-log-${SUFFIX_${buildtype}}.txt")
        endif()
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SUFFIX_${buildtype}}/meson-logs/install-log.txt")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SUFFIX_${buildtype}}/meson-logs/install-log.txt" DESTINATION "${CURRENT_BUILDTREES_DIR}")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/install-log.txt" "${CURRENT_BUILDTREES_DIR}/install-log-${SUFFIX_${buildtype}}.txt")
        endif()
        message(STATUS "Configuring ${TARGET_TRIPLET}-${SUFFIX_${buildtype}} done")

        #Restore PKG_CONFIG_PATH
        if(BACKUP_ENV_PKG_CONFIG_PATH_${buildtype})
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_${buildtype}}")
            unset(BACKUP_ENV_PKG_CONFIG_PATH_${buildtype})
        else()
            unset(ENV{PKG_CONFIG_PATH})
        endif()
    endforeach()

    if(VCPKG_TARGET_IS_OSX)
        if(DEFINED _VCPKG_ENV_SDKROOT_BACKUP)
            set(ENV{SDKROOT} "${_VCPKG_ENV_SDKROOT_BACKUP}")
        else()
            unset(ENV{SDKROOT})
        endif()
        if(DEFINED _VCPKG_ENV_MACOSX_DEPLOYMENT_TARGET_BACKUP)
            set(ENV{MACOSX_DEPLOYMENT_TARGET} "${_VCPKG_ENV_MACOSX_DEPLOYMENT_TARGET_BACKUP}")
        else()
            unset(ENV{MACOSX_DEPLOYMENT_TARGET})
        endif()
    endif()
endfunction()
