function(configure_qt)
    cmake_parse_arguments(_csc "" "SOURCE_PATH;TARGET_PLATFORM;HOST_PLATFORM;HOST_TOOLS_ROOT" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})

    if(NOT _csc_TARGET_PLATFORM)
        message(FATAL_ERROR "configure_qt requires a TARGET_PLATFORM argument.")
    endif()
    
    if(DEFINED _csc_HOST_PLATFORM)
        list(APPEND _csc_OPTIONS -platform ${_csc_HOST_PLATFORM})
    endif()
    
    if(DEFINED _csc_HOST_TOOLS_ROOT)
        ## vcpkg internal file struture assumed here!
        message(STATUS "Building Qt with prepared host tools from ${_csc_HOST_TOOLS_ROOT}!")
        vcpkg_add_to_path("${_csc_HOST_TOOLS_ROOT}/bin")
        vcpkg_add_to_path("${_csc_HOST_TOOLS_ROOT}")
        set(EXT_BIN_DIR -external-hostbindir ${_csc_HOST_TOOLS_ROOT}/bin) # we only use release binaries for building
        find_program(QMAKE_COMMAND NAMES qmake PATHS ${_csc_HOST_TOOLS_ROOT}/bin NO_DEFAULT_PATH)
        set(INVOKE "${QMAKE_COMMAND}" )
    else()
        if(CMAKE_HOST_WIN32)
            set(CONFIGURE_BAT "configure.bat")
        else()
            set(CONFIGURE_BAT "configure")
        endif()
        set(INVOKE "${_csc_SOURCE_PATH}/${CONFIGURE_BAT}")
    endif()

    #Cleanup previous build folders
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    #Find and ad Perl to PATH
    vcpkg_find_acquire_program(PERL)
    get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
    vcpkg_add_to_path("${PERL_EXE_PATH}")

    if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
        list(APPEND _csc_OPTIONS -static)
    else()
        #list(APPEND _csc_OPTIONS_DEBUG -separate-debug-info)
    endif()
   
    if(VCPKG_TARGET_IS_WINDOWS AND "${VCPKG_CRT_LINKAGE}" STREQUAL "static")
        list(APPEND _csc_OPTIONS -static-runtime)
    endif()

    list(APPEND _csc_OPTIONS_RELEASE -release)
    list(APPEND _csc_OPTIONS_DEBUG -debug)

    foreach(_buildname ${VCPKG_BUILD_LIST})
        set(_build_triplet ${VCPKG_BUILD_TRIPLET_${_buildname}})
        message(STATUS "Configuring ${_build_triplet}")
        set(_build_dir "${VCPKG_BUILDTREE_TRIPLET_DIR_${_buildname}}")
        file(MAKE_DIRECTORY ${_build_dir})
        # These paths get hardcoded into qmake. So point them into the CURRENT_INSTALLED_DIR instead of CURRENT_PACKAGES_DIR
        # makefiles will be fixed to install into CURRENT_PACKAGES_DIR in install_qt
        set(BUILD_OPTIONS ${_csc_OPTIONS} ${_csc_OPTIONS_${_buildname}}
                -prefix ${CURRENT_INSTALLED_DIR}
                -extprefix ${CURRENT_INSTALLED_DIR}
                ${EXT_BIN_DIR}
                -hostprefix ${CURRENT_INSTALLED_DIR}/tools/qt5${VCPKG_PATH_SUFFIX_${_buildname}}
                -hostlibdir ${CURRENT_INSTALLED_DIR}/tools/qt5${VCPKG_PATH_SUFFIX_${_buildname}}/lib # could probably be move to manual-link
                -hostbindir ${CURRENT_INSTALLED_DIR}/tools/qt5${VCPKG_PATH_SUFFIX_${_buildname}}/bin 
                # Qt VS Plugin requires a /bin subfolder with the executables in the root dir. But to use the wizard a correctly setup lib folder is also required
                # So with the vcpkg layout there is no way to make it work unless all dll are are copied to tools/qt5/bin and all libs to tools/qt5/lib
                -archdatadir ${CURRENT_INSTALLED_DIR}/tools/qt5${VCPKG_PATH_SUFFIX_${_buildname}}
                -datadir ${CURRENT_INSTALLED_DIR}${_path_suffix}/share/qt5${VCPKG_PATH_SUFFIX_${_buildname}}
                -plugindir ${CURRENT_INSTALLED_DIR}${VCPKG_PATH_SUFFIX_${_buildname}}/plugins
                -qmldir ${CURRENT_INSTALLED_DIR}${VCPKG_PATH_SUFFIX_${_buildname}}/qml
                -headerdir ${CURRENT_INSTALLED_DIR}/include
                -libexecdir ${CURRENT_INSTALLED_DIR}/tools/qt5${VCPKG_PATH_SUFFIX_${_buildname}}
                -bindir ${CURRENT_INSTALLED_DIR}${VCPKG_PATH_SUFFIX_${_buildname}}/bin
                -libdir ${CURRENT_INSTALLED_DIR}${VCPKG_PATH_SUFFIX_${_buildname}}/lib
                -I ${CURRENT_INSTALLED_DIR}/include
                -L ${CURRENT_INSTALLED_DIR}${VCPKG_PATH_SUFFIX_${_buildname}}/lib 
                -L ${CURRENT_INSTALLED_DIR}${VCPKG_PATH_SUFFIX_${_buildname}}/lib/manual-link
                -xplatform ${_csc_TARGET_PLATFORM}
            )
        
        if(DEFINED _csc_HOST_TOOLS_ROOT) #use qmake          
            if(WIN32)
                set(INVOKE_OPTIONS "QMAKE_CXX.QMAKE_MSC_VER=1911" "QMAKE_MSC_VER=1911")
            endif()
            vcpkg_execute_required_process(
                COMMAND ${INVOKE} "${_csc_SOURCE_PATH}" "${INVOKE_OPTIONS}" -- ${BUILD_OPTIONS}
                WORKING_DIRECTORY "${_build_dir}"
                LOGNAME config-${_build_triplet}
            )
        else()# call configure (builds qmake for triplet and calls it like above)
            vcpkg_execute_required_process(
                COMMAND "${INVOKE}" ${BUILD_OPTIONS}
                WORKING_DIRECTORY ${_build_dir}
                LOGNAME config-${_build_triplet}
            )
        endif()

        # Note archdatadir and datadir are required to be prefixed with the hostprefix? 
        message(STATUS "Configuring ${_build_triplet} done")
        
        # Copy configuration dependent qt.conf
        file(TO_CMAKE_PATH "${CURRENT_PACKAGES_DIR}" CMAKE_CURRENT_PACKAGES_DIR_PATH)
        file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}" CMAKE_CURRENT_INSTALLED_DIR_PATH)
        file(READ "${CURRENT_BUILDTREES_DIR}/${_build_triplet}/bin/qt.conf" _contents)
        string(REPLACE "${CMAKE_CURRENT_PACKAGES_DIR_PATH}" "\${CURRENT_INSTALLED_DIR}" _contents ${_contents})
        string(REPLACE "${CMAKE_CURRENT_INSTALLED_DIR_PATH}" "\${CURRENT_INSTALLED_DIR}" _contents ${_contents})
        #string(REPLACE "HostPrefix=\${CURRENT_PACKAGES_DIR}" "HostPrefix=\${CURRENT_INSTALLED_DIR}" _contents ${_contents})
        string(REPLACE "[EffectivePaths]\nPrefix=..\n" "" _contents ${_contents})
        string(REPLACE "[EffectiveSourcePaths]\nPrefix=${_csc_SOURCE_PATH}\n" "" _contents ${_contents})
        string(REPLACE "Sysroot=\n" "" _contents ${_contents})
        string(REPLACE "SysrootifyPrefix=false\n" "" _contents ${_contents})
        file(WRITE "${CURRENT_PACKAGES_DIR}/tools/qt5/qt_${_build_type_${_buildname}}.conf" "${_contents}")     
        
        unset(_build_triplet)
        unset(_build_dir)
    endforeach()  

endfunction()
