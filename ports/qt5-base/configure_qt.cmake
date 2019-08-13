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
    else()
        list(APPEND _csc_OPTIONS "-separate-debug-info")
    endif()
   
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
        list(APPEND _csc_OPTIONS "-static-runtime")
    endif()

    list(APPEND _csc_OPTIONS "-verbose")
    
    #list(APPEND _csc_OPTIONS -optimized-tools)    
    list(APPEND _csc_OPTIONS_RELEASE -force-debug-info)
    list(APPEND _csc_OPTIONS_RELEASE -ltcg)
    
    if(CMAKE_HOST_WIN32)
        set(CONFIGURE_BAT "configure.bat")
    else()
        set(CONFIGURE_BAT "configure")
    endif()
    
    #-external-hostbindir ${CURRENT_PACKAGES_DIR}${_path_suffix}/tools/qt5
    
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        set(_path_suffix "/debug")
        vcpkg_execute_required_process(
            COMMAND "${_csc_SOURCE_PATH}/${CONFIGURE_BAT}" ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}
                -debug  
                -prefix ${CURRENT_PACKAGES_DIR}
                -extprefix ${CURRENT_PACKAGES_DIR}
                -hostprefix ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}/host
                -hostlibdir ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}/host/lib
                -hostbindir ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}/host/bin
                -archdatadir ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}
                -datadir ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}
                -plugindir ${CURRENT_PACKAGES_DIR}/${_path_suffix}/plugins
                -qmldir ${CURRENT_PACKAGES_DIR}/${_path_suffix}/qml
                -headerdir ${CURRENT_PACKAGES_DIR}/include
                -libexecdir ${CURRENT_PACKAGES_DIR}${_path_suffix}/tools/qt5
                -bindir ${CURRENT_PACKAGES_DIR}${_path_suffix}/bin
                -libdir ${CURRENT_PACKAGES_DIR}${_path_suffix}/lib
                -I ${CURRENT_INSTALLED_DIR}/include
                -L ${CURRENT_INSTALLED_DIR}${_path_suffix}/lib 
                -L ${CURRENT_INSTALLED_DIR}${_path_suffix}/lib/manual-link
                -xplatform ${_csc_PLATFORM}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        set(_path_suffix "")
        vcpkg_execute_required_process(
            COMMAND "${_csc_SOURCE_PATH}/${CONFIGURE_BAT}" ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}
                -release
                -prefix ${CURRENT_PACKAGES_DIR}
                -extprefix ${CURRENT_PACKAGES_DIR}
                -hostprefix ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}/host
                -hostlibdir ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}/host/lib
                -hostbindir ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}/host/bin
                -archdatadir ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}
                -datadir ${CURRENT_PACKAGES_DIR}/share/qt5${_path_suffix}
                -plugindir ${CURRENT_PACKAGES_DIR}/${_path_suffix}/plugins
                -qmldir ${CURRENT_PACKAGES_DIR}/${_path_suffix}/qml
                -headerdir ${CURRENT_PACKAGES_DIR}/include
                -libexecdir ${CURRENT_PACKAGES_DIR}${_path_suffix}/tools/qt5
                -bindir ${CURRENT_PACKAGES_DIR}${_path_suffix}/bin
                -libdir ${CURRENT_PACKAGES_DIR}${_path_suffix}/lib
                -I ${CURRENT_INSTALLED_DIR}/include
                -L ${CURRENT_INSTALLED_DIR}${_path_suffix}/lib 
                -L ${CURRENT_INSTALLED_DIR}${_path_suffix}/lib/manual-link
                -xplatform ${_csc_PLATFORM}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME config-${TARGET_TRIPLET}-rel
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
    endif()

endfunction()
