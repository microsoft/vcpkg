include("${CMAKE_CURRENT_LIST_DIR}/qt_install_copyright.cmake")

if(QT_IS_LATEST AND PORT STREQUAL "qtbase")
    include("${CMAKE_CURRENT_LIST_DIR}/qt_port_details-latest.cmake")
else()
    include("${CMAKE_CURRENT_LIST_DIR}/qt_port_details.cmake")
endif()
#set(PORT_DEBUG ON)

if(NOT DEFINED QT6_DIRECTORY_PREFIX)
    set(QT6_DIRECTORY_PREFIX "Qt6/")
endif()

macro(qt_stop_on_update)
    if(QT_UPDATE_VERSION)
        set(VCPKG_POLICY_EMPTY_PACKAGE enabled CACHE INTERNAL "")
        return()
    endif()
endmacro()

function(qt_download_submodule)
    cmake_parse_arguments(PARSE_ARGV 0 "_qarg" ""
                      ""
                      "PATCHES")

    if(QT_UPDATE_VERSION)
        set(VCPKG_USE_HEAD_VERSION ON)
        set(UPDATE_PORT_GIT_OPTIONS
                HEAD_REF "${QT_GIT_TAG}")
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH
        URL "https://code.qt.io/qt/${PORT}.git"
        #TAG ${${PORT}_TAG}
        REF "${${PORT}_REF}"
        ${UPDATE_PORT_GIT_OPTIONS}
        PATCHES ${_qarg_PATCHES}
    )

    if(QT_UPDATE_VERSION)
        set(VCPKG_POLICY_EMPTY_PACKAGE enabled CACHE INTERNAL "")
        message(STATUS "VCPKG_HEAD_VERSION:${VCPKG_HEAD_VERSION}")
        file(APPEND "${VCPKG_ROOT_DIR}/ports/qtbase/cmake/qt_new_refs.cmake" "set(${PORT}_REF ${VCPKG_HEAD_VERSION})\n")
    endif()
    set(SOURCE_PATH "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()


function(qt_cmake_configure)
    cmake_parse_arguments(PARSE_ARGV 0 "_qarg" "DISABLE_NINJA"
                      ""
                      "TOOL_NAMES;OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE")
    
    vcpkg_find_acquire_program(PERL) # Perl is probably required by all qt ports for syncqt
    get_filename_component(PERL_PATH ${PERL} DIRECTORY)
    vcpkg_add_to_path(${PERL_PATH})
    if(NOT PORT STREQUAL "qtwebengine") # qtwebengine requires python2
        vcpkg_find_acquire_program(PYTHON3) # Python is required by some qt ports
        get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
        vcpkg_add_to_path(${PYTHON3_PATH})
    endif()

    if(CMAKE_HOST_WIN32)
        if(NOT ${PORT} MATCHES "qtbase")
            list(APPEND _qarg_OPTIONS -DQT_SYNCQT:PATH="${CURRENT_HOST_INSTALLED_DIR}/tools/Qt6/bin/syncqt.pl")
        endif()
        set(PERL_OPTION -DHOST_PERL:PATH="${PERL}")
    else()
        if(NOT ${PORT} MATCHES "qtbase")
            list(APPEND _qarg_OPTIONS -DQT_SYNCQT:PATH=${CURRENT_HOST_INSTALLED_DIR}/tools/Qt6/bin/syncqt.pl)
        endif()
        set(PERL_OPTION -DHOST_PERL:PATH=${PERL})
    endif()

    if(NOT _qarg_DISABLE_NINJA)
        set(NINJA_OPTION PREFER_NINJA)
    endif()

    if(VCPKG_CROSSCOMPILING)
        list(APPEND _qarg_OPTIONS -DQT_HOST_PATH=${CURRENT_HOST_INSTALLED_DIR})
        list(APPEND _qarg_OPTIONS -DQT_HOST_PATH_CMAKE_DIR:PATH=${CURRENT_HOST_INSTALLED_DIR}/share)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 AND VCPKG_TARGET_IS_WINDOWS) # Remove if PR #16111 is merged
            list(APPEND _qarg_OPTIONS -DCMAKE_CROSSCOMPILING=ON -DCMAKE_SYSTEM_PROCESSOR:STRING=ARM64 -DCMAKE_SYSTEM_NAME:STRING=Windows)
        endif()
    endif()

    vcpkg_configure_cmake(
        SOURCE_PATH "${SOURCE_PATH}"
        ${NINJA_OPTION}
        OPTIONS 
            #-DQT_HOST_PATH=<somepath> # For crosscompiling
            #-DQT_PLATFORM_DEFINITION_DIR=mkspecs/win32-msvc
            #-DQT_QMAKE_TARGET_MKSPEC=win32-msvc
            #-DQT_USE_CCACHE
            -DQT_NO_MAKE_EXAMPLES:BOOL=TRUE
            -DQT_NO_MAKE_TESTS:BOOL=TRUE
            ${PERL_OPTION}
            -DINSTALL_BINDIR:STRING=bin
            -DINSTALL_LIBEXECDIR:STRING=bin
            -DINSTALL_PLUGINSDIR:STRING=${qt_plugindir}
            -DINSTALL_QMLDIR:STRING=${qt_qmldir}
            ${_qarg_OPTIONS}
        OPTIONS_RELEASE
            ${_qarg_OPTIONS_RELEASE}
            -DINSTALL_DOCDIR:STRING=doc/${QT6_DIRECTORY_PREFIX}
            -DINSTALL_INCLUDEDIR:STRING=include/${QT6_DIRECTORY_PREFIX}
            -DINSTALL_DESCRIPTIONSDIR:STRING=share/Qt6/modules
            -DINSTALL_MKSPECSDIR:STRING=share/Qt6/mkspecs
            -DINSTALL_TRANSLATIONSDIR:STRING=translations/${QT6_DIRECTORY_PREFIX}
        OPTIONS_DEBUG
            -DINPUT_debug:BOOL=ON
            -DINSTALL_DOCDIR:STRING=../doc/${QT6_DIRECTORY_PREFIX}
            -DINSTALL_INCLUDEDIR:STRING=../include/${QT6_DIRECTORY_PREFIX}
            -DINSTALL_TRANSLATIONSDIR:STRING=../translations/${QT6_DIRECTORY_PREFIX}
            -DINSTALL_DESCRIPTIONSDIR:STRING=../share/Qt6/modules
            -DINSTALL_MKSPECSDIR:STRING=../share/Qt6/mkspecs
            ${_qis_CONFIGURE_OPTIONS_DEBUG}
    )
    set(Z_VCPKG_CMAKE_GENERATOR "${Z_VCPKG_CMAKE_GENERATOR}" PARENT_SCOPE)
endfunction()

function(qt_fixup_and_cleanup)
        cmake_parse_arguments(PARSE_ARGV 0 "_qarg" ""
                      ""
                      "TOOL_NAMES")
    vcpkg_copy_pdbs()

    ## Handle CMake files. 
    set(COMPONENTS)
    file(GLOB COMPONENTS_OR_FILES LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/share/Qt6*")
    list(REMOVE_ITEM COMPONENTS_OR_FILES "${CURRENT_PACKAGES_DIR}/share/Qt6")
    foreach(_glob IN LISTS COMPONENTS_OR_FILES)
        if(IS_DIRECTORY "${_glob}")
            string(REPLACE "${CURRENT_PACKAGES_DIR}/share/Qt6" "" _component "${_glob}")
            debug_message("Adding cmake component: '${_component}'")
            list(APPEND COMPONENTS ${_component})
        endif()
    endforeach()

    foreach(_comp IN LISTS COMPONENTS)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/share/Qt6${_comp}")
            vcpkg_fixup_cmake_targets(CONFIG_PATH share/Qt6${_comp} TARGET_PATH share/Qt6${_comp} TOOLS_PATH "tools/Qt6/bin")
            # Would rather put it into share/cmake as before but the import_prefix correction in vcpkg_fixup_cmake_targets is working against that. 
        else()
            message(STATUS "WARNING: Qt component ${_comp} not found/built!")
        endif()
    endforeach()
    #fix debug plugin paths (should probably be fixed in vcpkg_fixup_pkgconfig)
    file(GLOB_RECURSE DEBUG_CMAKE_TARGETS "${CURRENT_PACKAGES_DIR}/share/**/*Targets-debug.cmake")
    debug_message("DEBUG_CMAKE_TARGETS:${DEBUG_CMAKE_TARGETS}")
    foreach(_debug_target IN LISTS DEBUG_CMAKE_TARGETS)
        vcpkg_replace_string("${_debug_target}" "{_IMPORT_PREFIX}/${qt_plugindir}" "{_IMPORT_PREFIX}/debug/${qt_plugindir}")
        vcpkg_replace_string("${_debug_target}" "{_IMPORT_PREFIX}/${qt_qmldir}" "{_IMPORT_PREFIX}/debug/${qt_qmldir}")
    endforeach()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(GLOB_RECURSE STATIC_CMAKE_TARGETS "${CURRENT_PACKAGES_DIR}/share/Qt6Qml/QmlPlugins/*.cmake")
        foreach(_plugin_target IN LISTS STATIC_CMAKE_TARGETS)
            # restore a single get_filename_component which was remove by vcpkg_fixup_pkgconfig
            vcpkg_replace_string("${_plugin_target}" 
                                 [[get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)]]
                                 "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)")
        endforeach()
    endif()

    set(qt_tooldest "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin")
    set(qt_searchdir "${CURRENT_PACKAGES_DIR}/bin")
    ## Handle Tools
    foreach(_tool IN LISTS _qarg_TOOL_NAMES)
        if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
            debug_message("Removed '${_tool}' from copy tools list since it was not found!")
            list(REMOVE_ITEM _qarg_TOOL_NAMES ${_tool})
        endif()
    endforeach()
    if(_qarg_TOOL_NAMES)
        set(tool_names ${_qarg_TOOL_NAMES})
        vcpkg_copy_tools(TOOL_NAMES ${tool_names} SEARCH_DIR "${qt_searchdir}" DESTINATION "${qt_tooldest}" AUTO_CLEAN)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/${qt_plugindir}")
            file(COPY "${CURRENT_PACKAGES_DIR}/${qt_plugindir}/" DESTINATION "${qt_tooldest}")
        endif()
    endif()

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/")
            file(COPY "${CURRENT_PACKAGES_DIR}/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin")
        endif()
        file(GLOB_RECURSE _installed_dll_files RELATIVE "${CURRENT_INSTALLED_DIR}/tools/Qt6/bin" "${CURRENT_INSTALLED_DIR}/tools/Qt6/bin/*.dll")
        foreach(_dll_to_remove IN LISTS _installed_dll_files)
            file(GLOB_RECURSE _packaged_dll_file "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/${_dll_to_remove}")
            if(EXISTS "${_packaged_dll_file}")
                file(REMOVE "${_packaged_dll_file}")
            endif()
        endforeach()
        file(GLOB_RECURSE _folders LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/**/")
        file(GLOB_RECURSE _files "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/**/")
        if(_files)
            list(REMOVE_ITEM _folders ${_files})
        endif()
        foreach(_dir IN LISTS _folders)
            if(NOT "${_remaining_dll_files}" MATCHES "${_dir}")
                file(REMOVE_RECURSE "${_dir}")
            endif()
        endforeach()
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/"
                        "${CURRENT_PACKAGES_DIR}/debug/share"
                        "${CURRENT_PACKAGES_DIR}/lib/cmake/"
                        )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(GLOB_RECURSE _bin_files "${CURRENT_PACKAGES_DIR}/bin/*")
        debug_message("Files in bin: '${_bin_files}'")
        if(NOT _bin_files) # Only clean if empty otherwise let vcpkg throw and error. 
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/debug/bin/")
        endif()
    endif()

endfunction()

function(qt_install_submodule)
    cmake_parse_arguments(PARSE_ARGV 0 "_qis" "DISABLE_NINJA"
                          ""
                          "PATCHES;TOOL_NAMES;CONFIGURE_OPTIONS;CONFIGURE_OPTIONS_DEBUG;CONFIGURE_OPTIONS_RELEASE")

    set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
    set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

    qt_download_submodule(PATCHES ${_qis_PATCHES})
    if(QT_UPDATE_VERSION)
        return()
    endif()

    if(_qis_DISABLE_NINJA)
        set(_opt DISABLE_NINJA)
    endif()
    qt_cmake_configure(${_opt} 
                       OPTIONS ${_qis_CONFIGURE_OPTIONS}
                       OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                       OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

    vcpkg_install_cmake(ADD_BIN_TO_PATH)

    qt_fixup_and_cleanup(TOOL_NAMES ${_qis_TOOL_NAMES})

    qt_install_copyright("${SOURCE_PATH}")
    set(SOURCE_PATH "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()