include_guard(GLOBAL)

function(vcpkg_xcode_build)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "INSTALL;DISABLE_PARALLEL" "SOURCE_PATH;PROJECT_FILE;TARGET;LOGFILE_BASE;SCHEME" "")

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
    if (NOT arg_DISABLE_PARALLEL)
        vcpkg_list(APPEND build_param "-parallelizeTargets")
    endif()

    if(arg_TARGET)
        vcpkg_list(APPEND target_param "-target" "${arg_TARGET}")
    elseif(arg_SCHEME)
        vcpkg_list(APPEND build_param "-scheme" "${arg_SCHEME}")
    else()
        vcpkg_list(APPEND target_param "-alltargets")
    endif()

    vcpkg_list(APPEND build_param "-project" "${arg_SOURCE_PATH}/${PROJECT_FILE}" "-verbose")

    if (arg_INSTALL)
        vcpkg_list(APPEND build_param "archive" )
    endif()

    foreach(build_type IN ITEMS debug release)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "${build_type}")
            if("${build_type}" STREQUAL "debug")
                set(short_build_type "dbg")
                set(config "Debug")
                if (arg_INSTALL)
                    set(install_param "DSTROOT=${CURRENT_PACKAGES_DIR}/debug")
                endif()
            else()
                set(short_build_type "rel")
                set(config "Release")
                if (arg_INSTALL)
                    set(install_param "DSTROOT=${CURRENT_PACKAGES_DIR}")
                endif()
            endif()

            message(STATUS "Building ${TARGET_TRIPLET}-${short_build_type}")

            debug_message("command:\nxcodebuild ${build_param} ${target_param} -configuration ${config} SYMROOT=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type} ${install_param}")
            vcpkg_execute_build_process(
                COMMAND
                    xcodebuild ${build_param} ${target_param} -configuration "${config}" 
                    SYMROOT="${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
                    ${install_param}
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
                LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}-${short_build_type}"
            )
        endif()
    endforeach()
endfunction()
