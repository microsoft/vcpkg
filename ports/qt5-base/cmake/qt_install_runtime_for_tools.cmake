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

    if(NOT arg_LIBRARIES AND NOT EXISTS "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
        return()
    endif()

    if(PORT STREQUAL "qt5-base")
        block(SCOPE_FOR VARIABLES)
        set(qt_conf "${CURRENT_PACKAGES_DIR}/tools/qt5/qt_${config}.conf")
        string(REPLACE "/debug" "/.." CURRENT_INSTALLED_DIR "./../../..${path_suffix}") # Making the qt.conf relative and not absolute
        configure_file("${qt_conf}" "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/qt.conf") # This makes the tools at least useable for release
        endblock()
    endif()

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        foreach(lib IN LISTS arg_LIBRARIES)
            string(APPEND lib "${dll_suffix}")
            if(EXISTS "${CURRENT_PACKAGES_DIR}${path_suffix}/bin/${lib}.dll") # subject to features
                file(COPY "${CURRENT_PACKAGES_DIR}${path_suffix}/bin/${lib}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
            elseif(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix}/bin/${lib}.dll") # subject to features
                message("${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" "${PORT} tools require ${lib} but the port does not own this DLL.")
                file(COPY "${CURRENT_INSTALLED_DIR}${path_suffix}/bin/${lib}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
            else()
                message(STATUS "${lib} is not installed. Assuming a disabled feature.")
            endif()
        endforeach()

        # Not using vcpkg_copy_tool_dependencies / deployqt.ps1
        # because they cannot handle port tools in shared directories.
        file(GLOB tools "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/*.exe")
        file(GLOB libs "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin/*.dll")
        file(GLOB installed_libs "${CURRENT_INSTALLED_DIR}/tools/qt5${path_suffix}/bin/*.dll")
        # TODO: inspect only necessary plugins and qml modules
        file(GLOB plugins "${CURRENT_PACKAGES_DIR}${path_suffix}/plugins/*/*.dll")
        file(GLOB qml "${CURRENT_PACKAGES_DIR}${path_suffix}/qml/*/*.dll")
        file(GET_RUNTIME_DEPENDENCIES
            RESOLVED_DEPENDENCIES_VAR resolved
            UNRESOLVED_DEPENDENCIES_VAR unresolved
            EXECUTABLES ${tools}
            LIBRARIES ${libs}
            MODULES ${plugins} ${qml}
            DIRECTORIES
                "${CURRENT_INSTALLED_DIR}/tools/qt5${path_suffix}/bin"
                "${CURRENT_PACKAGES_DIR}${path_suffix}/bin"
                "${CURRENT_INSTALLED_DIR}${path_suffix}/bin"
        )
        list(REMOVE_ITEM resolved ${libs} ${installed_libs})
        foreach(lib IN LISTS resolved)
            string(FIND "${lib}" "${CURRENT_PACKAGES_DIR}${path_suffix}/bin" in_packages)
            string(FIND "${lib}" "${CURRENT_INSTALLED_DIR}${path_suffix}/bin" in_installed)
            if(in_packages EQUAL "0" OR in_installed EQUAL "0")
                file(INSTALL "${lib}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin")
            endif()
        endforeach()
        if(unresolved)
            message(WARNING "Unresolved: ${unresolved}")
        endif()
    endif()

    file(COPY "${CURRENT_PACKAGES_DIR}/tools/qt5${path_suffix}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}${path_suffix}")
endfunction()
