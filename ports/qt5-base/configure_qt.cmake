function(configure_qt)
    cmake_parse_arguments(_csc "" "SOURCE_PATH;PLATFORM" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})

    if (_csc_PLATFORM)
        set(PLATFORM ${_csc_PLATFORM})
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v140")
        set(PLATFORM "win32-msvc2015")
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(PLATFORM "win32-msvc2017")
    endif()

    vcpkg_find_acquire_program(PERL)
    get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH}")

    if(DEFINED VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL static)
        list(APPEND _csc_OPTIONS
            "-static"
            "-static-runtime"
        )
    endif()

    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_execute_required_process(
        COMMAND "${_csc_SOURCE_PATH}/configure.bat" ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}
            -debug
            -prefix ${CURRENT_PACKAGES_DIR}/debug
            -hostbindir ${CURRENT_PACKAGES_DIR}/debug/tools/qt5
            -archdatadir ${CURRENT_PACKAGES_DIR}/share/qt5/debug
            -datadir ${CURRENT_PACKAGES_DIR}/share/qt5/debug
            -plugindir ${CURRENT_PACKAGES_DIR}/debug/plugins
            -qmldir ${CURRENT_PACKAGES_DIR}/debug/qml
            -headerdir ${CURRENT_PACKAGES_DIR}/include
            -I ${CURRENT_INSTALLED_DIR}/include
            -L ${CURRENT_INSTALLED_DIR}/debug/lib
            -platform ${PLATFORM}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME config-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
    
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND "${_csc_SOURCE_PATH}/configure.bat" ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}
            -release
            -prefix ${CURRENT_PACKAGES_DIR}
            -hostbindir ${CURRENT_PACKAGES_DIR}/tools/qt5
            -archdatadir ${CURRENT_PACKAGES_DIR}/share/qt5
            -datadir ${CURRENT_PACKAGES_DIR}/share/qt5
            -plugindir ${CURRENT_PACKAGES_DIR}/plugins
            -qmldir ${CURRENT_PACKAGES_DIR}/qml
            -I ${CURRENT_INSTALLED_DIR}/include
            -L ${CURRENT_INSTALLED_DIR}/lib
            -platform ${PLATFORM}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME config-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

endfunction()