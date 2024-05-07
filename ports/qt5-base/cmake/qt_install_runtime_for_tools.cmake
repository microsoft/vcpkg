# Copy additional runtime libraries to the shared tools/qt5/bin location
#
# To ensure predictable ownership regardless of installation order,
# each port must install its own DLLs, qml libs and plugins
# if they are needed (in terms of qtdeploy.ps1) by downstream ports.
function(qt_install_runtime_for_tools)
    if(NOT VCPKG_BUILD_TYPE)
        z_qt_install_runtime_for_tools(debug "/debug" "d" ${ARGV})
    endif()
    z_qt_install_runtime_for_tools(release "" "" ${ARGV})
endfunction()

function(z_qt_install_runtime_for_tools config path_suffix dll_suffix)
    set(arg_LIBRARIES "${ARGN}")

    # Temporarily clone qtdeploy.ps1 --- applocal.ps1 loads it from <search_dir>/../plugins.
    if(VCPKG_TARGET_IS_WINDOWS)
        file(COPY "${CURRENT_INSTALLED_DIR}/plugins/qtdeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}${path_suffix}/plugins")
    endif()

    if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
        set(qt_conf "${CURRENT_INSTALLED_DIR}/tools/qt5/qt_${config}.conf")
        if(PORT STREQUAL "qt5-base")
            set(qt_conf "${CURRENT_PACKAGES_DIR}/tools/qt5/qt_${config}.conf")
        endif()
        file(REMOVE "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/qt.conf")
        set(CURRENT_INSTALLED_DIR_BACKUP "${CURRENT_INSTALLED_DIR}")
        string(REPLACE "/debug" "/.." CURRENT_INSTALLED_DIR "./../../..${path_suffix}") # Making the qt.conf relative and not absolute
        configure_file("${qt_conf}" "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/qt.conf") # This makes the tools at least useable for release
        set(CURRENT_INSTALLED_DIR "${CURRENT_INSTALLED_DIR_BACKUP}")

        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
        file(COPY "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}${path_suffix}")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # qtdeploy.ps1 is tuned for user projects (one run), not ports (two runs). Fill gaps.
        if(EXISTS "${CURRENT_PACKAGES_DIR}${path_suffix}/qml")
            if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/${PORT}${path_suffix}/bin/Qt5Qml${dll_suffix}.dll")
                # qml libs from CURRENT_INSTALLED_DIR already copied by vcpkg_copy_tool_dependencies.
                file(COPY "${CURRENT_PACKAGES_DIR}${path_suffix}/qml" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}${path_suffix}/bin")
                file(COPY "${CURRENT_PACKAGES_DIR}${path_suffix}/qml" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
            elseif("Qt5Qml" IN_LIST arg_LIBRARIES)
                # qml libs as runtime for tools
                file(COPY "${CURRENT_INSTALLED_DIR}${path_suffix}/qml" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
            endif()
        endif()
        set(rerun_copy_tool_dependencies FALSE)
        foreach(lib IN LISTS arg_LIBRARIES)
            string(APPEND lib "${dll_suffix}")
            if(EXISTS "${CURRENT_PACKAGES_DIR}${path_suffix}/bin/${lib}.dll") # subject to features
                file(COPY "${CURRENT_PACKAGES_DIR}${path_suffix}/bin/${lib}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
                set(rerun_copy_tool_dependencies TRUE)
            elseif(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix}/bin/${lib}.dll") # subject to features
                # trigger for plugin deployment
                file(COPY "${CURRENT_INSTALLED_DIR}${path_suffix}/bin/${lib}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
                set(rerun_copy_tool_dependencies TRUE)
            else()
                # probably a disabled feature
                message(STATUS "No such lib: ${lib}")
            endif()
        endforeach()
        if(rerun_copy_tool_dependencies)
            vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
        endif()
    endif()

    # Remove temporary clones and runtime files which are already owned by other ports
    file(GLOB files RELATIVE "${CURRENT_PACKAGES_DIR}"
        "${CURRENT_PACKAGES_DIR}${path_suffix}/plugins/qtdeploy.ps1"
        "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/qt.conf"
        "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/*.dll"
        "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/plugins/*/*.dll"
        "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/qml/*" # files and dirs
    )
    foreach(file IN LISTS files)
        if(EXISTS "${CURRENT_INSTALLED_DIR}/${file}")
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${file}")
        endif()
    endforeach()

    # Prune empty runtime dirs
    file(GLOB plugin_dirs "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/plugins/*")
    set(base_dirs
        "${CURRENT_PACKAGES_DIR}${path_suffix}/bin"
        "${CURRENT_PACKAGES_DIR}${path_suffix}/lib"
        "${CURRENT_PACKAGES_DIR}${path_suffix}/plugins"
        "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/plugins"
        "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/qml"
    )
    foreach(dir IN LISTS plugin_dirs base_dirs)
        file(GLOB plugins "${dir}/*")
        if("${plugins}" STREQUAL "")
            file(REMOVE_RECURSE "${dir}")
        endif()
    endforeach()
endfunction()
