include_guard(GLOBAL)

function(vcpkg_xcode_build)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "ENABLE_INSTALL;DISABLE_PARALLEL" "SOURCE_PATH;PROJECT_FILE;TARGET;LOGFILE_BASE;SCHEME" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_xcode_build was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if (NOT arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be declared")
    endif()

    if (arg_TARGET AND arg_SCHEME)
        message(FATAL_ERROR "TARGET and SCHEME only be selected one of them")
    endif()

    if(NOT DEFINED arg_LOGFILE_BASE)
        set(arg_LOGFILE_BASE "build")
    endif()
    vcpkg_list(SET build_param)
    vcpkg_list(SET parallel_param)
    vcpkg_list(SET no_parallel_param)

    vcpkg_list(SET target_param)

    if (NOT "${arg_PROJECT_FILE}" STREQUAL "")
        set(PROJECT_FILE "${arg_PROJECT_FILE}")
    else()
        get_filename_component(PROJECT_FILE "${arg_SOURCE_PATH}" NAME)
        set(PROJECT_FILE "${PROJECT_FILE}.xcodeproj")
    endif()

    # build options
    # official doc: https://developer.apple.com/library/archive/technotes/tn2339/_index.html
    # https://developer.apple.com/library/archive/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html
    if (NOT arg_DISABLE_PARALLEL)
        vcpkg_list(APPEND build_param "-parallelizeTargets" "-jobs" "${VCPKG_CONCURRENCY}")
    else()
        vcpkg_list(APPEND build_param "-jobs" "1")
    endif()

    if(arg_TARGET)
        vcpkg_list(APPEND target_param "-target" "${arg_TARGET}")
    elseif(arg_SCHEME)
        vcpkg_list(APPEND build_param "-scheme" "${arg_SCHEME}")
    else()
        vcpkg_list(APPEND target_param "-alltargets")
    endif()

    #if (VCPKG_TARGET_IS_OSX)
    #    vcpkg_list(APPEND build_param "-scheme" "macOS")
    #elseif (VCPKG_TARGET_IS_IOS)
    #    vcpkg_list(APPEND build_param "-scheme" "iOS")
    #endif()

    vcpkg_list(APPEND build_param "-project" "${arg_SOURCE_PATH}/${PROJECT_FILE}" "-verbose")
    #vcpkg_list(APPEND build_param "DYLIB_INSTALL_NAME_BASE=lib" "INSTALL_PATH=lib")

    if (arg_ENABLE_INSTALL)
        vcpkg_list(APPEND build_param "archive" )
    endif()

    foreach(build_type IN ITEMS debug release)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "${build_type}")
            set(INSTALL_PATH "")
            if("${build_type}" STREQUAL "debug")
                set(short_build_type "dbg")
                set(config "Debug")
                if (arg_ENABLE_INSTALL)
                    set(INSTALL_PATH "${CURRENT_PACKAGES_DIR}/debug")
                    set(install_param "DSTROOT=${INSTALL_PATH}" "SYMROOT=${INSTALL_PATH}")
                endif()
            else()
                set(short_build_type "rel")
                set(config "Release")
                if (arg_ENABLE_INSTALL)
                    set(INSTALL_PATH "${CURRENT_PACKAGES_DIR}")
                    set(install_param "DSTROOT=${INSTALL_PATH}" "SYMROOT=${INSTALL_PATH}")
                endif()
            endif()

            vcpkg_list(APPEND install_param "TARGET_BUILD_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}" "OBJROOT=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}")

            if (EXISTS "${${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}}")
                file(REMOVE_RECURSE "${${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}}")
            endif()
            file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}")

            message(STATUS "Building ${TARGET_TRIPLET}-${short_build_type}")

            debug_message("command:\nxcodebuild ${build_param} ${target_param} -configuration ${config} ${install_param}")
            vcpkg_execute_build_process(
                COMMAND
                    xcodebuild ${build_param} ${target_param} -configuration "${config}"
                    ${install_param}
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
                LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}-${short_build_type}"
            )

            if (arg_ENABLE_INSTALL)
                if (EXISTS "${INSTALL_PATH}/${config}/include")
                    message("rename include path")
                    file(RENAME "${INSTALL_PATH}/${config}/include" "${INSTALL_PATH}/include")
                endif()

                file(GLOB_RECURSE install_symlink_list LIST_DIRECTORIES false "${INSTALL_PATH}/${config}/*")
                foreach (install_symlink IN LISTS install_symlink_list)
                    if (IS_SYMLINK "${install_symlink}")
                        file(READ_SYMLINK "${install_symlink}" target_binary_path)
                        file(COPY ${target_binary_path} DESTINATION "${INSTALL_PATH}/lib")
                    endif()
                endforeach()

                file(REMOVE_RECURSE "${INSTALL_PATH}/${config}")
            endif()
        endif()
    endforeach()
endfunction()
