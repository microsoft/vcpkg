function(vcpkg_install_meson)
    cmake_parse_arguments(PARSE_ARGV 0 arg "ADD_BIN_TO_PATH" "" "")

    vcpkg_find_acquire_program(NINJA)
    unset(ENV{DESTDIR}) # installation directory was already specified with '--prefix' option

    if(VCPKG_TARGET_IS_OSX)
        vcpkg_backup_env_variables(VARS SDKROOT MACOSX_DEPLOYMENT_TARGET)
        set(ENV{SDKROOT} "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
        set(ENV{MACOSX_DEPLOYMENT_TARGET} "${VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()

    foreach(buildtype IN ITEMS "debug" "release")
        if(DEFINED VCPKG_BUILD_TYPE AND NOT VCPKG_BUILD_TYPE STREQUAL buildtype)
            continue()
        endif()

        if(buildtype STREQUAL "debug")
            set(short_buildtype "dbg")
        else()
            set(short_buildtype "rel")
        endif()

        message(STATUS "Package ${TARGET_TRIPLET}-${short_buildtype}")
        if(arg_ADD_BIN_TO_PATH)
            vcpkg_backup_env_variables(VARS PATH)
            if(buildtype STREQUAL "debug")
                vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
            else()
                vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
            endif()
        endif()
        vcpkg_execute_required_process(
            COMMAND "${NINJA}" install -v
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_buildtype}"
            LOGNAME package-${TARGET_TRIPLET}-${short_buildtype}
        )
        if(arg_ADD_BIN_TO_PATH)
            vcpkg_restore_env_variables(VARS PATH)
        endif()
    endforeach()

    vcpkg_list(SET renamed_libs)
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL static AND NOT VCPKG_TARGET_IS_MINGW)
        # Meson names all static libraries lib<name>.a which basically breaks the world
        file(GLOB_RECURSE gen_libraries "${CURRENT_PACKAGES_DIR}*/**/lib*.a")
        foreach(gen_library IN LISTS gen_libraries)
            get_filename_component(libdir "${gen_library}" DIRECTORY)
            get_filename_component(libname "${gen_library}" NAME)
            string(REGEX REPLACE ".a$" ".lib" fixed_librawname "${libname}")
            string(REGEX REPLACE "^lib" "" fixed_librawname "${fixed_librawname}")
            file(RENAME "${gen_library}" "${libdir}/${fixed_librawname}")
            # For cmake fixes.
            string(REGEX REPLACE ".a$" "" origin_librawname "${libname}")
            string(REGEX REPLACE ".lib$" "" fixed_librawname "${fixed_librawname}")
            vcpkg_list(APPEND renamed_libs ${fixed_librawname})
            set(${librawname}_old ${origin_librawname})
            set(${librawname}_new ${fixed_librawname})
        endforeach()
        file(GLOB_RECURSE cmake_files "${CURRENT_PACKAGES_DIR}*/*.cmake")
        foreach(cmake_file IN LISTS cmake_files)
            foreach(current_lib IN LISTS renamed_libs)
                vcpkg_replace_string("${cmake_file}" "${${current_lib}_old}" "${${current_lib}_new}")
            endforeach()
        endforeach()
    endif()

    if(VCPKG_TARGET_IS_OSX)
        vcpkg_restore_env_variables(VARS SDKROOT MACOSX_DEPLOYMENT_TARGET)
    endif()
endfunction()
