
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

    # Setup Build tools
    set(QMAKE_COMMAND "${CURRENT_HOST_INSTALLED_DIR}/tools/Qt6/bin/qmake${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    set(qmake_build_tools "")
    vcpkg_list(APPEND qmake_build_tools "QMAKE_CC=${VCPKG_DETECTED_CMAKE_C_COMPILER}"
                                        "QMAKE_CXX=${VCPKG_DETECTED_CMAKE_CXX_COMPILER}"
                                        "QMAKE_AR=${VCPKG_DETECTED_CMAKE_AR}"
                                        "QMAKE_RANLIB=${VCPKG_DETECTED_CMAKE_RANLIB}"
                                        "QMAKE_STRIP=${VCPKG_DETECTED_CMAKE_STRIP}"
                                        "QMAKE_NM=${VCPKG_DETECTED_CMAKE_NM}"
                                        "QMAKE_RC=${VCPKG_DETECTED_CMAKE_RC_COMPILER}"
                                        "QMAKE_MT=${VCPKG_DETECTED_CMAKE_MT}"
                )
    # QMAKE_OBJCOPY ?
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        get_filename_component(LINKER "${VCPKG_DETECTED_CMAKE_LINKER}" NAME)
        vcpkg_list(APPEND qmake_build_tools "QMAKE_LINK=${LINKER}"
                                            "QMAKE_LINK_C=${LINKER}"
                  )
    else()
        vcpkg_list(APPEND qmake_build_tools "QMAKE_LINK=${VCPKG_DETECTED_CMAKE_CXX_COMPILER}"
                                            "QMAKE_LINK_C=${VCPKG_DETECTED_CMAKE_C_COMPILER}"
                  )
    endif()

    foreach(buildtype IN LISTS buildtypes)
        set(short "${short_name_${buildtype}}")
        string(TOLOWER "${buildtype}" lowerbuildtype)
        set(prefix "${CURRENT_INSTALLED_DIR}${path_suffix_${buildtype}}")
        set(prefix_package "${CURRENT_PACKAGES_DIR}${path_suffix_${buildtype}}")
        set(config_triplet "${TARGET_TRIPLET}-${short}")
        # Cleanup build directories
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${config_triplet}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/Qt6/qt_${lowerbuildtype}.conf" "${CURRENT_BUILDTREES_DIR}/${config_triplet}/qt.conf") # Needs probably more TODO for cross builds

        vcpkg_backup_env_variables(VARS PKG_CONFIG_PATH)
        vcpkg_host_path_list(PREPEND PKG_CONFIG_PATH "${prefix}/lib/pkgconfig" "${prefix}/share/pkgconfig")

        set(qmake_comp_flags "")
        vcpkg_list(APPEND qmake_comp_flags "QMAKE_LIBS+=${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}" 
                                           "QMAKE_RC+=${VCPKG_DETECTED_CMAKE_RC_FLAGS_${buildtype}}"
                                           "QMAKE_CFLAGS_${buildtype}*=${VCPKG_DETECTED_CMAKE_C_FLAGS_${buildtype}}"
                                           "QMAKE_CXXFLAGS_${buildtype}*=${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${buildtype}}"
                                           "QMAKE_LFLAGS*=${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${buildtype}}"
                                           "QMAKE_LFLAGS_DLL*=${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${buildtype}}"
                                           "QMAKE_LFLAGS_EXE*=${VCPKG_DETECTED_CMAKE_EXE_LINKER_FLAGS_${buildtype}}")

        message(STATUS "Configuring ${config_triplet}")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${config_triplet}")
        if(DEFINED arg_OPTIONS OR DEFINED arg_OPTIONS_${buildtype})
            set(options -- ${arg_OPTIONS} ${arg_OPTIONS_${buildtype}})
        endif()
        vcpkg_execute_required_process(
            COMMAND ${QMAKE_COMMAND} ${qmake_config_${buildtype}}
                    ${arg_QMAKE_OPTIONS} ${arg_QMAKE_OPTIONS_DEBUG}
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