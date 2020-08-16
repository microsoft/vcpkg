## # vcpkg_configure_meson
##
## Configure Meson for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_meson(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `meson.build`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### OPTIONS
## Additional options passed to Meson during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to Meson during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to Meson during the Debug configuration. These are in addition to `OPTIONS`.
##
## ## Notes
## This command supplies many common arguments to Meson. To see the full list, examine the source.
##
## ## Examples
##
## * [fribidi](https://github.com/Microsoft/vcpkg/blob/master/ports/fribidi/portfile.cmake)
## * [libepoxy](https://github.com/Microsoft/vcpkg/blob/master/ports/libepoxy/portfile.cmake)

function(generate_native_file) #https://mesonbuild.com/Native-environments.html
    set(NATIVE "[binaries]\n")
    set(proglist AR RANLIB STRIP NM OBJDUMP DLLTOOL MT)
    foreach(prog IN LISTS proglist)
        if(VCPKG_DETECTED_${prog})
            string(TOLOWER "${prog}" proglower)
            string(APPEND NATIVE "${proglower} = '${VCPKG_DETECTED_${prog}}'\n")
        endif()
    endforeach()
    set(compiler C CXX RC)
    foreach(prog IN LISTS compiler)
        if(VCPKG_DETECTED_${prog}_COMPILER)
            string(REPLACE "CXX" "CPP" mesonprog "${prog}")
            string(TOLOWER "${mesonprog}" proglower)
            string(APPEND NATIVE "${proglower} = '${VCPKG_DETECTED_${prog}_COMPILER}'\n")
        endif()
    endforeach()
    if(VCPKG_DETECTED_LINKER)
        string(APPEND NATIVE "c_ld = '${VCPKG_DETECTED_LINKER}'\n")
        string(APPEND NATIVE "cpp_ld = '${VCPKG_DETECTED_LINKER}'\n")
    endif()
    string(APPEND NATIVE "cmake = '${CMAKE_COMMAND}'\n")
    
    string(APPEND NATIVE "[built-in options]\n") #https://mesonbuild.com/Builtin-options.html
    if(VCPKG_DETECTED_C_COMPILER MATCHES "cl.exe")
        string(APPEND NATIVE "cpp_eh='none'\n") # To make sure meson is not adding eh flags by itself using msvc
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        string(REGEX REPLACE "( |^)(-|/)" ";\\2" WIN_C_STANDARD_LIBRARIES "${VCPKG_DETECTED_C_STANDARD_LIBRARIES}")
        list(TRANSFORM WIN_C_STANDARD_LIBRARIES APPEND "'")
        list(TRANSFORM WIN_C_STANDARD_LIBRARIES PREPEND "'")
        list(JOIN WIN_C_STANDARD_LIBRARIES ", " WIN_C_STANDARD_LIBRARIES)
        string(APPEND NATIVE "c_winlibs = [${WIN_C_STANDARD_LIBRARIES}]\n")
        string(REGEX REPLACE "( |^)(-|/)" ";\\2" WIN_CXX_STANDARD_LIBRARIES "${VCPKG_DETECTED_CXX_STANDARD_LIBRARIES}")
        list(TRANSFORM WIN_CXX_STANDARD_LIBRARIES APPEND "'")
        list(TRANSFORM WIN_CXX_STANDARD_LIBRARIES PREPEND "'")
        list(JOIN WIN_CXX_STANDARD_LIBRARIES ", " WIN_CXX_STANDARD_LIBRARIES)
        string(APPEND NATIVE "cpp_winlibs = [${WIN_CXX_STANDARD_LIBRARIES}]\n")
    endif()

    set(_file "${CURRENT_BUILDTREES_DIR}/meson-nativ-${TARGET_TRIPLET}.log")
    set(VCPKG_MESON_NATIVE_FILE "${_file}" PARENT_SCOPE)
    file(WRITE "${_file}" "${NATIVE}")
endfunction()

function(generate_native_file_config _config) #https://mesonbuild.com/Native-environments.html
    set(NATIVE_${_config} "[built-in options]\n") #https://mesonbuild.com/Builtin-options.html
    string(REGEX REPLACE "( |^)(-|/)" ";\\2" MESON_CFLAGS_${_config} "${VCPKG_DETECTED_COMBINED_CFLAGS_${_config}}")
    list(TRANSFORM MESON_CFLAGS_${_config} APPEND "'")
    list(TRANSFORM MESON_CFLAGS_${_config} PREPEND "'")
    list(JOIN MESON_CFLAGS_${_config} ", " MESON_CFLAGS_${_config})
    string(APPEND NATIVE_${_config} "c_args = [${MESON_CFLAGS_${_config}}]\n")
    string(REGEX REPLACE "( |^)(-|/)" ";\\2" MESON_CXXFLAGS_${_config} "${VCPKG_DETECTED_COMBINED_CXXFLAGS_${_config}}")
    list(TRANSFORM MESON_CXXFLAGS_${_config} APPEND "'")
    list(TRANSFORM MESON_CXXFLAGS_${_config} PREPEND "'")
    list(JOIN MESON_CXXFLAGS_${_config} ", " MESON_CXXFLAGS_${_config})
    string(APPEND NATIVE_${_config} "cpp_args = [${MESON_CXXFLAGS_${_config}}]\n")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(LINKER_FLAGS_${_config} "${VCPKG_DETECTED_COMBINED_SHARED_LINKERFLAGS_${_config}}")
    else()
        set(LINKER_FLAGS_${_config} "${VCPKG_DETECTED_COMBINED_STATIC_LINKERFLAGS_${_config}}")
    endif()
    string(REGEX REPLACE "( |^)(-|/)" ";\\2" LINKER_FLAGS_${_config} "${LINKER_FLAGS_${_config}}")
    list(TRANSFORM LINKER_FLAGS_${_config} APPEND "'")
    list(TRANSFORM LINKER_FLAGS_${_config} PREPEND "'")
    list(JOIN LINKER_FLAGS_${_config} ", " LINKER_FLAGS_${_config})
    string(APPEND NATIVE_${_config} "c_linker_args = [${LINKER_FLAGS_${_config}}]\n")
    string(APPEND NATIVE_${_config} "cpp_linker_args = [${LINKER_FLAGS_${_config}}]\n")

    string(TOLOWER "${_config}" lowerconfig)
    set(_file "${CURRENT_BUILDTREES_DIR}/meson-nativ-${TARGET_TRIPLET}-${lowerconfig}.log")
    set(VCPKG_MESON_NATIVE_FILE_${_config} "${_file}" PARENT_SCOPE)
    file(WRITE "${_file}" "${NATIVE_${_config}}")
endfunction()

function(generate_cross_file) #https://mesonbuild.com/Cross-compilation.html
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(BUILD_ARCH $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(BUILD_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(BUILD_ARCH MATCHES "(amd|AMD)64")
        set(BUILD_CPU_FAM x86_x64)
        set(BUILD_CPU x86_x64)
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
        message(FATAL_ERROR "Unsupported host architecture ${BUILD_ARCH}!" )
    endif()

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(amd|AMD|x|X)64")
        set(HOST_CPU_FAM x86_x64)
        set(HOST_CPU x86_x64)
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
    
    set(CROSS "")
    string(APPEND CROSS "[properties]\n")
    string(APPEND CROSS "skip_sanity_check = true")
    string(APPEND CROSS "[host_machine]\n")
    string(APPEND CROSS "endian = 'little'\n")
    string(APPEND CROSS "system = '${VCPKG_CMAKE_SYSTEM_NAME}'\n")
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
    string(APPEND CROSS "cpu_family = '${BUILD_CPU_FAM}'\n")
    string(APPEND CROSS "cpu = '${BUILD_CPU}'\n")
    
    if(NOT BUILD_CPU_FAM STREQUAL HOST_CPU_FAM)
        set(_file "${CURRENT_BUILDTREES_DIR}/meson-cross-${TARGET_TRIPLET}.log")
        set(VCPKG_MESON_CROSS_FILE "${_file}" PARENT_SCOPE)
        file(WRITE "${_file}" "${NATIVE}")
    endif()
endfunction()



function(vcpkg_configure_meson)
    cmake_parse_arguments(_vcm "" "SOURCE_PATH" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    vcpkg_get_cmake_vars(OUTPUT_FILE CMAKE_VARS_FILE)
    set(CMAKE_VARS_FILE "${CMAKE_VARS_FILE}" PARENT_SCOPE)
    debug_message("Including cmake vars from: ${CMAKE_VARS_FILE}")
    include("${CMAKE_VARS_FILE}")

    list(APPEND _vcm_OPTIONS --buildtype plain --backend ninja --wrap-mode nodownload)

    if(NOT VCPKG_MESON_NATIVE_FILE)
        generate_native_file()
    endif()
    if(NOT VCPKG_MESON_NATIVE_FILE_DEBUG)
        generate_native_file_config(DEBUG)
    endif()
    if(NOT VCPKG_MESON_NATIVE_FILE_RELEASE)
        generate_native_file_config(RELEASE)
    endif()
    list(APPEND _vcm_OPTIONS --native "${VCPKG_MESON_NATIVE_FILE}")
    list(APPEND _vcm_OPTIONS_DEBUG --native "${VCPKG_MESON_NATIVE_FILE_DEBUG}")
    list(APPEND _vcm_OPTIONS_RELEASE --native "${VCPKG_MESON_NATIVE_FILE_RELEASE}")

    if(NOT VCPKG_MESON_CROSS_FILE)
        generate_cross_file()
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

    vcpkg_find_acquire_program(MESON)

    get_filename_component(CMAKE_PATH ${CMAKE_COMMAND} DIRECTORY)
    vcpkg_add_to_path("${CMAKE_PATH}") # Make CMake invokeable for Meson

    if(NOT DEFINED ENV{PKG_CONFIG})
        find_program(PKGCONFIG pkg-config)
        if(NOT PKGCONFIG AND CMAKE_HOST_WIN32)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
            vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
        endif()
        find_program(PKGCONFIG pkg-config REQUIRED)
    else()
        debug_message(STATUS "PKG_CONFIG found in ENV! Using $ENV{PKG_CONFIG}")
        set(PKGCONFIG $ENV{PKG_CONFIG})
    endif()
    set(PKGCONFIG_SHARE_DIR "${CURRENT_INSTALLED_DIR}/share/pkgconfig/")
    if(WIN32) # Can be removed with a native pkg-config
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" PKGCONFIG_SHARE_DIR "${PKGCONFIG_SHARE_DIR}")
    endif()
    
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
    # configure debug
    foreach(buildtype IN LISTS buildtypes)
        message(STATUS "Configuring ${TARGET_TRIPLET}-${SUFFIX_${buildtype}}")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SUFFIX_${buildtype}}")
        set(ENV{PKG_CONFIG} "${PKGCONFIG}") # Set via native file?
                set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}/${PATH_SUFFIX_${buildtype}}lib/pkgconfig/")
        if(WIN32) # Can be removed with a native pkg-config
            string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" PKGCONFIG_INSTALLED_DIR "${PKGCONFIG_INSTALLED_DIR}")
        endif()
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_${buildtype} $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}:${PKGCONFIG_SHARE_DIR}:$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}:${PKGCONFIG_SHARE_DIR}")
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
endfunction()
