if(COMMAND z_vcpkg_cmake_validate_build)
    return()
endif()

function(z_vcpkg_cmake_validate_build)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "COUNT;LABEL;CMAKE;VERSION"
        "CMAKE_PROLOGUE;FIND_PACKAGE;LIBRARIES_VARIABLES;TARGETS;HEADERS;FUNCTIONS"
    )
    if(NOT arg_FIND_PACKAGE)
        message(FATAL_ERROR "The FIND_PACKAGE argument is mandatory.")
    endif()
    if(NOT arg_CMAKE)
        set(arg_CMAKE "${CMAKE_COMMAND}")
        set(arg_VERSION "${CMAKE_VERSION}")
    endif()
    if(NOT arg_COUNT)
        set(arg_COUNT 0)
    endif()
    if(NOT arg_LABEL)
        list(JOIN arg_FIND_PACKAGE " " arg_LABEL)
    endif()

    # Break absolute paths. (Actual renaming done in tighter scope)
    set(current_packages_dir_relocated "${CURRENT_PACKAGES_DIR}_relocated")
    set(cmake_args
        "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-cmake-validate/project"
        "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
        "-DCURRENT_PACKAGES_DIR=${current_packages_dir_relocated}"
        "-DVCPKG_INSTALLED_DIR=${_VCPKG_INSTALLED_DIR}"
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_MANIFEST_MODE=OFF"
    )

    if(NINJA)
        list(APPEND cmake_args -G Ninja "-DCMAKE_MAKE_PROGRAM=${NINJA}")
    endif()

    if(VCPKG_TARGET_IS_UWP)
        list(APPEND cmake_args "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            list(APPEND cmake_args "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
        endif()
        if(DEFINED VCPKG_PLATFORM_TOOLSET)
            list(APPEND cmake_args "-DVCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}")
        endif()
    endif()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND cmake_args -DBUILD_SHARED_LIBS=ON)
    else()
        list(APPEND cmake_args -DBUILD_SHARED_LIBS=OFF)
    endif()

    set(build_types Release)
    if(NOT DEFINED VCPKG_BUILD_TYPE)
        list(APPEND build_types Debug)
    else()
        list(APPEND cmake_args -DCHECK_DEBUG=OFF)
    endif()
    foreach(build_type IN LISTS build_types)
        string(MAKE_C_IDENTIFIER "${arg_LABEL}" identifier)
        string(REGEX REPLACE "([-_])_*" "\\1" identifier "validate-${arg_COUNT}-${identifier}-${arg_VERSION}-${TARGET_TRIPLET}")
        if(build_type STREQUAL "Debug")
            string(APPEND identifier "_dbg")
        endif()
        set(build_prefix "${CURRENT_BUILDTREES_DIR}/checks/${identifier}")
        file(REMOVE_RECURSE "${build_prefix}")
        file(MAKE_DIRECTORY "${build_prefix}")

        file(REMOVE_RECURSE "${current_packages_dir_relocated}")
        file(RENAME "${CURRENT_PACKAGES_DIR}" "${current_packages_dir_relocated}")

        # To produce better error messages for failing wrappers,
        # we run execute_process directly here.
        set(step "configuration")
        set(log_out "${build_prefix}-config-out.log")
        set(log_err "${build_prefix}-config-err.log")
        execute_process(
            COMMAND "${arg_CMAKE}"
                "-DLABEL=${arg_LABEL}, ${build_type}"
                "-DCMAKE_BUILD_TYPE=${build_type}"
                "-DCMAKE_INSTALL_PREFIX=${build_prefix}/install"
                "-DPROLOGUE=${arg_CMAKE_PROLOGUE}"
                "-DFIND_PACKAGE_ARGS=${arg_FIND_PACKAGE}"
                "-DLIBRARIES_VARIABLES=${arg_LIBRARIES_VARIABLES}"
                "-DTARGETS=${arg_TARGETS}"
                "-DHEADERS=${arg_HEADERS}"
                "-DFUNCTIONS=${arg_FUNCTIONS}"
                ${cmake_args}
            WORKING_DIRECTORY "${build_prefix}"
            OUTPUT_FILE "${log_out}"
            ERROR_FILE "${log_err}"
            RESULT_VARIABLE result
        )
        if(NOT result AND (arg_HEADERS OR arg_FUNCTIONS))
            set(step "build")
            set(log_out "${build_prefix}-build-out.log")
            set(log_err "${build_prefix}-build-err.log")
            execute_process(
                COMMAND "${arg_CMAKE}" --build .
                WORKING_DIRECTORY "${build_prefix}"
                OUTPUT_FILE "${log_out}"
                ERROR_FILE "${log_err}"
                RESULT_VARIABLE result
            )
        endif()
        file(RENAME "${current_packages_dir_relocated}" "${CURRENT_PACKAGES_DIR}")

        if(result)
            # Forward error messages to console
            file(STRINGS "${log_err}" errors REGEX "Validation failed: ")
            list(TRANSFORM errors REPLACE "Validation failed: " "")
            list(TRANSFORM errors APPEND "\n")

            set(message "  ")
            if(DEFINED ENV{BUILD_REASON}) # On Azure Pipelines, add extra markup.
                set(message "##vso[task.logissue type=error]")
            endif()
            string(APPEND message "CMake ${arg_VERSION}: `find_package(${args_string})` validation failed at ${step} step for '${build_type}'.\n"
                ${errors}
                "  See logs for more information:\n"
                "    ${log_out}\n"
                "    ${log_err}\n"
            )

            # For CI failure log collection, put the logs into CURRENT_BUILDTREES_DIR.
            file(COPY "${log_out}" "${log_err}" DESTINATION "${CURRENT_BUILDTREES_DIR}/")
            string(REPLACE "/${TARGET_TRIPLET}_checks/" "/" message "${message}")
            message(SEND_ERROR "${message}")
            break()
        endif()
    endforeach()
endfunction()
