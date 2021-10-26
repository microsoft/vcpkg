#[===[.md:
# vcpkg_qmake_configure

Configure a qmake-based project.

###User setable triplet variables:
VCPKG_OSX_DEPLOYMENT_TARGET: Determines QMAKE_MACOSX_DEPLOYMENT_TARGET
VCPKG_QMAKE_COMMAND: Path to qmake. (default: "${CURRENT_HOST_INSTALLED_DIR}/tools/Qt6/bin/qmake${VCPKG_HOST_EXECUTABLE_SUFFIX}")
VCPKG_QT_CONF_(RELEASE|DEBUG): Path to qt.config being used for RELEASE/DEBUG. (default: "${CURRENT_INSTALLED_DIR}/tools/Qt6/qt_(release|debug).conf")
VCPKG_QMAKE_OPTIONS(_RELEASE|_DEBUG)?: Extra options to pass to QMake

```cmake
vcpkg_qmake_configure(
    SOURCE_PATH <pro_file_path>
    [QMAKE_OPTIONS arg1 [arg2 ...]]
    [QMAKE_OPTIONS_RELEASE arg1 [arg2 ...]]
    [QMAKE_OPTIONS_DEBUG arg1 [arg2 ...]]
    [OPTIONS arg1 [arg2 ...]]
    [OPTIONS_RELEASE arg1 [arg2 ...]]
    [OPTIONS_DEBUG arg1 [arg2 ...]]
)
```

### SOURCE_PATH
The path to the *.pro qmake project file.

### QMAKE_OPTIONS, QMAKE_OPTIONS\_RELEASE, QMAKE_OPTIONS\_DEBUG
options directly passed to qmake with the form QMAKE_X=something or CONFIG=something 

### OPTIONS, OPTIONS\_RELEASE, OPTIONS\_DEBUG
The options passed after -- to qmake.

#]===]
include_guard(GLOBAL)
function(vcpkg_qmake_configure)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "SOURCE_PATH" "QMAKE_OPTIONS;QMAKE_OPTIONS_RELEASE;QMAKE_OPTIONS_DEBUG;OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG")

    vcpkg_cmake_get_vars(detected_file)
    include("${detected_file}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND arg_QMAKE_OPTIONS "CONFIG-=shared")
        vcpkg_list(APPEND arg_QMAKE_OPTIONS "CONFIG*=static")
    else()
        vcpkg_list(APPEND arg_QMAKE_OPTIONS "CONFIG-=static")
        vcpkg_list(APPEND arg_QMAKE_OPTIONS "CONFIG*=shared")
        vcpkg_list(APPEND arg_QMAKE_OPTIONS_DEBUG "CONFIG*=separate_debug_info")
    endif()
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND _csc_QMAKE_OPTIONS "CONFIG*=static-runtime")
    endif()

    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} "${VCPKG_OSX_DEPLOYMENT_TARGET}")
    endif()

    set(ENV{PKG_CONFIG} "${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    get_filename_component(PKGCONFIG_PATH "${PKGCONFIG}" DIRECTORY)
    vcpkg_add_to_path("${PKGCONFIG_PATH}")

    set(buildtypes "")
    if(NOT VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "debug")
        list(APPEND buildtypes "DEBUG") # Using uppercase to also access the detected cmake variables with it
        set(path_suffix_DEBUG "debug/")
        set(short_name_DEBUG "dbg")
        set(qmake_config_DEBUG CONFIG+=debug CONFIG-=release)
    endif()
    if(NOT VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "release")
        list(APPEND buildtypes "RELEASE")
        set(path_suffix_RELEASE "")
        set(short_name_RELEASE "rel")
        set(qmake_config_RELEASE CONFIG-=debug CONFIG+=release)
    endif()

    function(qmake_append_program var qmake_var value)
        get_filename_component(prog "${value}" NAME)
        # QMake assumes everything is on PATH?
        vcpkg_list(APPEND ${var} "${qmake_var}=${prog}")
        find_program(${qmake_var} NAMES "${prog}")
        cmake_path(COMPARE "${${qmake_var}}" EQUAL "${value}" correct_prog_on_path)
        if(NOT correct_prog_on_path AND NOT "${value}" MATCHES "|:")
            message(FATAL_ERROR "Detect path mismatch for '${qmake_var}'. '${value}' is not the same as '${${qmake_var}}'. Please correct your PATH!")
        endif()
        unset(${qmake_var})
        unset(${qmake_var} CACHE)
        set(${var} "${${var}}" PARENT_SCOPE) # Is this correct? Or is there a vcpkg_list command for that?
    endfunction()
    # Setup Build tools
    if(NOT VCPKG_QMAKE_COMMAND) # For users using outside Qt6
        set(VCPKG_QMAKE_COMMAND "${CURRENT_HOST_INSTALLED_DIR}/tools/Qt6/bin/qmake${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()

    set(qmake_build_tools "")
    qmake_append_program(qmake_build_tools "QMAKE_CC" "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
    qmake_append_program(qmake_build_tools "QMAKE_CXX" "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
    qmake_append_program(qmake_build_tools "QMAKE_AR" "${VCPKG_DETECTED_CMAKE_AR}")
    qmake_append_program(qmake_build_tools "QMAKE_RANLIB" "${VCPKG_DETECTED_CMAKE_RANLIB}")
    qmake_append_program(qmake_build_tools "QMAKE_STRIP" "${VCPKG_DETECTED_CMAKE_STRIP}")
    qmake_append_program(qmake_build_tools "QMAKE_NM" "${VCPKG_DETECTED_CMAKE_NM}")
    qmake_append_program(qmake_build_tools "QMAKE_RC" "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
    qmake_append_program(qmake_build_tools "QMAKE_MT" "${VCPKG_DETECTED_CMAKE_MT}")

    # QMAKE_OBJCOPY ?
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        qmake_append_program(qmake_build_tools "LINKER" "${VCPKG_DETECTED_CMAKE_LINKER}")
        qmake_append_program(qmake_build_tools "QMAKE_LINK" "${VCPKG_DETECTED_CMAKE_LINKER}")
        qmake_append_program(qmake_build_tools "QMAKE_LINK_C" "${VCPKG_DETECTED_CMAKE_LINKER}")
    else()
        qmake_append_program(qmake_build_tools "QMAKE_LINK" "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
        qmake_append_program(qmake_build_tools "QMAKE_LINK_C" "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
    endif()

    foreach(buildtype IN LISTS buildtypes)
        set(short "${short_name_${buildtype}}")
        string(TOLOWER "${buildtype}" lowerbuildtype)
        set(prefix "${CURRENT_INSTALLED_DIR}${path_suffix_${buildtype}}")
        set(prefix_package "${CURRENT_PACKAGES_DIR}${path_suffix_${buildtype}}")
        set(config_triplet "${TARGET_TRIPLET}-${short}")
        # Cleanup build directories
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${config_triplet}")

        # Setup qt.conf
        if(NOT VCPKG_QT_CONF_${buildtype})
            set(VCPKG_QT_CONF_${buildtype} "${CURRENT_INSTALLED_DIR}/tools/Qt6/qt_${lowerbuildtype}.conf")
        endif()
        configure_file("${VCPKG_QT_CONF_${buildtype}}" "${CURRENT_BUILDTREES_DIR}/${config_triplet}/qt.conf") # Needs probably more TODO for cross builds

        vcpkg_backup_env_variables(VARS PKG_CONFIG_PATH)
        vcpkg_host_path_list(PREPEND PKG_CONFIG_PATH "${prefix}/lib/pkgconfig" "${prefix}/share/pkgconfig")

        set(qmake_comp_flags "")
        # Note sure about these. VCPKG_QMAKE_OPTIONS offers a way to opt out of these. (earlier values being overwritten by later values; = set +=append *=append unique -=remove)
        vcpkg_list(APPEND qmake_comp_flags "QMAKE_LIBS+=${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}" 
                                           "QMAKE_RC+=${VCPKG_DETECTED_CMAKE_RC_FLAGS_${buildtype}}"
                                           "QMAKE_CFLAGS_${buildtype}*=${VCPKG_DETECTED_CMAKE_C_FLAGS_${buildtype}}"
                                           "QMAKE_CXXFLAGS_${buildtype}*=${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${buildtype}}"
                                           "QMAKE_LFLAGS*=${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${buildtype}}"
                                           "QMAKE_LFLAGS_DLL*=${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${buildtype}}"
                                           "QMAKE_LFLAGS_EXE*=${VCPKG_DETECTED_CMAKE_EXE_LINKER_FLAGS_${buildtype}}"
                                           )

        message(STATUS "Configuring ${config_triplet}")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${config_triplet}")
        if(DEFINED arg_OPTIONS OR DEFINED arg_OPTIONS_${buildtype})
            set(options -- ${arg_OPTIONS} ${arg_OPTIONS_${buildtype}})
        endif()
        # Options might need to go into a response file? I am a bit concerned about cmd line length. 
        vcpkg_execute_required_process(
            COMMAND ${VCPKG_QMAKE_COMMAND} ${qmake_config_${buildtype}}
                    ${arg_QMAKE_OPTIONS} ${arg_QMAKE_OPTIONS_DEBUG}
                    ${VCPKG_QMAKE_OPTIONS} ${VCPKG_QMAKE_OPTIONS_${buildtype}} # Advanced users need a way to inject QMAKE variables via the triplet.
                    ${qmake_build_tools} ${qmake_comp_flags}
                    "${arg_SOURCE_PATH}"
                    -qtconf "${CURRENT_BUILDTREES_DIR}/${config_triplet}/qt.conf"
                    ${options}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${config_triplet}
            LOGNAME config-${config_triplet}
        )
        message(STATUS "Configuring ${config_triplet} done")

        vcpkg_restore_env_variables(VARS PKG_CONFIG_PATH)
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${config_triplet}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${config_triplet}.log")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/${config_triplet}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${config_triplet}.log")
        endif()
    endforeach()
endfunction()