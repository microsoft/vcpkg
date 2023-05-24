include(qt_fix_makefile_install)

function(install_qt)
    if(CMAKE_HOST_WIN32)
        if(VCPKG_TARGET_IS_MINGW)
            find_program(MINGW32_MAKE mingw32-make REQUIRED)
            set(INVOKE "${MINGW32_MAKE}" -j${VCPKG_CONCURRENCY})
            set(INVOKE_SINGLE "${MINGW32_MAKE}" -j1)
        elseif (VCPKG_QMAKE_USE_NMAKE)
            find_program(NMAKE nmake REQUIRED)
            set(INVOKE "${NMAKE}")
            set(INVOKE_SINGLE "${NMAKE}")
            get_filename_component(NMAKE_EXE_PATH ${NMAKE} DIRECTORY)
            set(PATH_GLOBAL "$ENV{PATH}")
            set(ENV{PATH} "$ENV{PATH};${NMAKE_EXE_PATH}")
            set(ENV{CL} "$ENV{CL} /MP${VCPKG_CONCURRENCY}")
        else()
            vcpkg_find_acquire_program(JOM)
            set(INVOKE "${JOM}" /J ${VCPKG_CONCURRENCY})
            set(INVOKE_SINGLE "${JOM}" /J 1)
        endif()
    else()
        find_program(MAKE make)
        set(INVOKE "${MAKE}" -j${VCPKG_CONCURRENCY})
        set(INVOKE_SINGLE "${MAKE}" -j1)
    endif()
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

    if (CMAKE_HOST_WIN32)
    # flex and bison for ANGLE library
    vcpkg_find_acquire_program(FLEX)
    get_filename_component(FLEX_EXE_PATH ${FLEX} DIRECTORY)
    get_filename_component(FLEX_DIR ${FLEX_EXE_PATH} NAME)

    file(COPY ${FLEX_EXE_PATH} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-tools" )
    set(FLEX_TEMP "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-tools/${FLEX_DIR}")
    file(RENAME "${FLEX_TEMP}/win_bison.exe" "${FLEX_TEMP}/bison.exe")
    file(RENAME "${FLEX_TEMP}/win_flex.exe" "${FLEX_TEMP}/flex.exe")
    vcpkg_add_to_path("${FLEX_TEMP}")
   endif()

   set(_path "$ENV{PATH}")

    #Replace with VCPKG variables if PR #7733 is merged
    unset(BUILDTYPES)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(_buildname "DEBUG")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "dbg")
        set(_path_suffix_${_buildname} "/debug")
        set(_build_type_${_buildname} "debug")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_buildname "RELEASE")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "rel")
        set(_path_suffix_${_buildname} "")
        set(_build_type_${_buildname} "release")
    endif()
    unset(_buildname)

    foreach(_buildname ${BUILDTYPES})
        set(_build_triplet ${TARGET_TRIPLET}-${_short_name_${_buildname}})

        set(_installed_prefix_ "${CURRENT_INSTALLED_DIR}${_path_suffix_${_buildname}}")
        set(_installed_libpath_ "${_installed_prefix_}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_installed_prefix_}/lib/manual-link/")

        vcpkg_add_to_path(PREPEND "${_installed_prefix_}/bin")
        vcpkg_add_to_path(PREPEND "${_installed_prefix_}/lib")

        # We set LD_LIBRARY_PATH ENV variable to allow executing Qt tools (rcc,...) even with dynamic linking
        if(CMAKE_HOST_UNIX)
            if(DEFINED ENV{LD_LIBRARY_PATH})
                set(_ld_library_path_defined_ TRUE)
                set(_ld_library_path_backup_ $ENV{LD_LIBRARY_PATH})
                set(ENV{LD_LIBRARY_PATH} "${_installed_libpath_}${VCPKG_HOST_PATH_SEPARATOR}${_ld_library_path_backup_}")
            else()
                set(_ld_library_path_defined_ FALSE)
                set(ENV{LD_LIBRARY_PATH} "${_installed_libpath_}")
            endif()
        endif()

        message(STATUS "Building ${_build_triplet}")
        vcpkg_execute_build_process(
            COMMAND ${INVOKE}
            NO_PARALLEL_COMMAND ${INVOKE_SINGLE}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}
            LOGNAME build-${_build_triplet}
        )

        if(VCPKG_TARGET_IS_OSX)
           # For some reason there will be an error on MacOSX without this clean!
            message(STATUS "Cleaning after build before install ${_build_triplet}")
            vcpkg_execute_required_process(
                COMMAND ${INVOKE_SINGLE} clean
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}/qmake
                LOGNAME cleaning-after-build-${_build_triplet}
            )
        endif()

        message(STATUS "Fixing makefile installation path ${_build_triplet}")
        qt_fix_makefile_install("${CURRENT_BUILDTREES_DIR}/${_build_triplet}")
        message(STATUS "Installing ${_build_triplet}")
        vcpkg_execute_required_process(
            COMMAND ${INVOKE} install
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${_build_triplet}
            LOGNAME package-${_build_triplet}
        )
        message(STATUS "Package ${_build_triplet} done")
        set(ENV{PATH} "${_path}")

        # Restore backup
        if(CMAKE_HOST_UNIX)
            if(_ld_library_path_defined_)
                set(ENV{LD_LIBRARY_PATH} "${_ld_library_path_backup_}")                
            else()
                unset(ENV{LD_LIBRARY_PATH})
            endif()
        endif()
    endforeach()
endfunction()
