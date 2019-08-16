function(configure_qt)
    cmake_parse_arguments(_csc "" "SOURCE_PATH;PLATFORM" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})

    if(NOT _csc_PLATFORM)
        message(FATAL_ERROR "configure_qt requires a PLATFORM argument.")
    endif()

    vcpkg_find_acquire_program(PERL)
    get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_add_to_path("${PERL_EXE_PATH}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        list(APPEND _csc_OPTIONS "-static")
    endif()

    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        list(APPEND _csc_OPTIONS "-static-runtime")
    endif()

    if(CMAKE_HOST_WIN32)
        set(CONFIGURE_BAT "configure.bat")
    else()
        set(CONFIGURE_BAT "configure")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        vcpkg_execute_required_process(
            COMMAND "${_csc_SOURCE_PATH}/${CONFIGURE_BAT}" ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}
                -debug
                -prefix ${CURRENT_INSTALLED_DIR}/debug
                -extprefix ${CURRENT_PACKAGES_DIR}/debug
                -hostbindir ${CURRENT_PACKAGES_DIR}/debug/tools/qt5
                -archdatadir ${CURRENT_PACKAGES_DIR}/share/qt5/debug
                -datadir ${CURRENT_PACKAGES_DIR}/share/qt5/debug
                -plugindir ${CURRENT_INSTALLED_DIR}/debug/plugins
                -qmldir ${CURRENT_INSTALLED_DIR}/debug/qml
                -headerdir ${CURRENT_PACKAGES_DIR}/include
                -I ${CURRENT_INSTALLED_DIR}/include
                -L ${CURRENT_INSTALLED_DIR}/debug/lib
                -platform ${_csc_PLATFORM}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        vcpkg_execute_required_process(
            COMMAND "${_csc_SOURCE_PATH}/${CONFIGURE_BAT}" ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}
                -release
                -prefix ${CURRENT_INSTALLED_DIR}
                -extprefix ${CURRENT_PACKAGES_DIR}
                -hostbindir ${CURRENT_PACKAGES_DIR}/tools/qt5
                -archdatadir ${CURRENT_INSTALLED_DIR}/share/qt5
                -datadir ${CURRENT_INSTALLED_DIR}/share/qt5
                -plugindir ${CURRENT_INSTALLED_DIR}/plugins
                -qmldir ${CURRENT_INSTALLED_DIR}/qml
                -I ${CURRENT_INSTALLED_DIR}/include
                -L ${CURRENT_INSTALLED_DIR}/lib
                -platform ${_csc_PLATFORM}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME config-${TARGET_TRIPLET}-rel
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
    endif()

endfunction()
