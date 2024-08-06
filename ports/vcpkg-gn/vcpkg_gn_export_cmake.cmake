include_guard(GLOBAL)

# Provide a cmake target name (w/o namespace) in out_var
function(z_vcpkg_gn_get_cmake_target out_var gn_target)
    if(gn_target MATCHES "/([^:/]+):")
        string(REPLACE "/${CMAKE_MATCH_1}:${CMAKE_MATCH_1}" "/${CMAKE_MATCH_1}" gn_target "${gn_target}")
    endif()
    string(REGEX REPLACE "[:/]+" "::" target "unofficial/${PORT}${gn_target}")
    set("${out_var}" "${target}" PARENT_SCOPE)
endfunction()

# Put the target's compile definitions in out_var, subject to regex
function(z_vcpkg_gn_get_definitions out_var desc_json target regex)
    set(output "")
    if(regex)
        z_vcpkg_gn_list_from_json(output "${desc_json}" "${target}" "defines")
        list(FILTER output INCLUDE REGEX "${regex}")
    endif()
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()

# Put the target's link libraries in out_var
function(z_vcpkg_gn_get_link_libs out_var desc_json target)
    # We don't pass this variable explicitly now.
    separate_arguments(known_standard_libraries NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
    # From ldflags, we only want lib names or filepaths (cf. declare_external_from_pkgconfig)
    z_vcpkg_gn_list_from_json(ldflags "${desc_json}" "${target}" "ldflags")
    string(REPLACE "-isysroot;" "-isysroot " ldflags "${ldflags}")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        list(FILTER ldflags INCLUDE REGEX "[.]lib\$")
    else()
        list(FILTER ldflags INCLUDE REGEX "^-l|^/")
    endif()
    list(TRANSFORM ldflags REPLACE "^-l" "")
    z_vcpkg_gn_list_from_json(libs "${desc_json}" "${target}" "libs")
    vcpkg_list(SET frameworks)
    if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
        z_vcpkg_gn_list_from_json(frameworks "${desc_json}" "${target}" "frameworks")
        list(TRANSFORM frameworks REPLACE "^(.*)[.]framework\$" "-framework \\1")
    endif()
    vcpkg_list(SET output)
    foreach(lib IN LISTS frameworks ldflags libs)
        if(VCPKG_TARGET_IS_WINDOWS)
            string(TOLOWER "${lib}" lib_key)
        else()
            set(lib_key "{lib}")
        endif()
        if(lib_key IN_LIST known_standard_libraries)
            continue()
        endif()
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${z_vcpkg_${PORT}_root}" lib "${lib}")
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${z_vcpkg_${PORT}_root}" lib "${lib}")
        if(NOT lib MATCHES "^-L")
            vcpkg_list(REMOVE_ITEM output "${lib}")
        endif()
        vcpkg_list(APPEND output "${lib}")
    endforeach()
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()

# A revised variant of vcpkg_gn_install
function(z_vcpkg_gn_export_cmake_build_type)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "BUILD_TYPE;SOURCE_PATH;INSTALL_DIR;LABEL;DEFINITIONS_PATTERN" "TARGETS")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Internal error: z_vcpkg_gn_export_cmake_build_type was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(build_dir "${CURRENT_BUILDTREES_DIR}/${arg_LABEL}")

    # install and export
    set(logfile "${CURRENT_BUILDTREES_DIR}/export-cmake-${arg_LABEL}.log")
    file(WRITE "${logfile}" "")
    message(STATUS "Exporting cmake (${arg_LABEL})...")

    file(MAKE_DIRECTORY "${arg_INSTALL_DIR}/share/unofficial-${PORT}")

    file(READ "${CURRENT_BUILDTREES_DIR}/generate-${arg_LABEL}-project.json.log" project_json)
    string(JSON arg_SOURCE_PATH GET "${project_json}" build_settings root_path)
    if(NOT IS_DIRECTORY "${arg_SOURCE_PATH}")
        message(FATAL_ERROR "build settings root path is not a directory (${arg_SOURCE_PATH}).")
    endif()

    list(TRANSFORM arg_TARGETS PREPEND "//")
    list(TRANSFORM arg_TARGETS REPLACE "/([^/:]+)\$" "/\\1:\\1")
    z_vcpkg_gn_expand_targets(arg_TARGETS project_json "${arg_SOURCE_PATH}")

    string(JSON desc GET "${project_json}" "targets")

    string(TOUPPER "${arg_BUILD_TYPE}" cmake_build_type)
    set(cmake_config_genex [[\$<NOT:\$<CONFIG:DEBUG>>]])
    if(cmake_build_type STREQUAL "DEBUG")
        set(cmake_config_genex [[\$<CONFIG:DEBUG>]])
    endif()

    foreach(gn_target IN LISTS arg_TARGETS)
        z_vcpkg_gn_get_cmake_target(cmake_target "${gn_target}")
        set(add_target "add_library(${cmake_target} INTERFACE IMPORTED)")
        set(has_location "0")
        set(imported_location "")
        set(not_executable "1")
        string(JSON target_type GET "${desc}" "${gn_target}" "type")

        set(link_language "C")
        string(JSON sources ERROR_VARIABLE unused GET "${desc}" "${gn_target}" "sources")
        if(sources MATCHES "[.]cxx|[.]cpp")
            set(link_language "CXX")
        endif()

        z_vcpkg_gn_list_from_json(outputs "${desc}" "${gn_target}" "outputs")
        foreach(output IN LISTS outputs)
            if(CMAKE_HOST_WIN32)
                # absolute path (e.g. /C:/path/to/target.lib)
                string(REGEX REPLACE "^/([^/]:)" "\\1" output "${output}")
            endif()
            # relative path (e.g. //out/Release/target.lib)
            string(REGEX REPLACE "^//" "${arg_SOURCE_PATH}/" output "${output}")

            cmake_path(GET output FILENAME filename)
            set(add_target "add_library(${cmake_target} UNKNOWN IMPORTED)")
            set(destination "${arg_INSTALL_DIR}/lib")
            set(has_location "1")
            if(target_type STREQUAL "executable")
                set(add_target "add_executable(${cmake_target} IMPORTED)")
                set(destination "${arg_INSTALL_DIR}/tools/${PORT}")
                set(imported_location "${destination}/${filename}")
                set(not_executable "0")
            elseif(filename MATCHES "\\.(dll|pdb)\$")
                if(CMAKE_MATCH_1 STREQUAL "pdb" AND NOT EXISTS "${output}")
                    continue()
                endif()
                set(destination "${arg_INSTALL_DIR}/bin")
                # Do not set (overwrite) imported_location
            else()
                set(imported_location "${destination}/${filename}")
            endif()
        endforeach()

        # CMake target properties
        string(REPLACE "::" "-" basename "${cmake_target}")
        z_vcpkg_gn_get_definitions(interface_compile_definitions "${desc}" "${gn_target}" "${arg_DEFINITIONS_PATTERN}")
        z_vcpkg_gn_get_link_libs(interface_link_libs "${desc}" "${gn_target}")
        set(interface_link_targets "")
        z_vcpkg_gn_list_from_json(deps "${desc}" "${gn_target}" "deps")
        list(REMOVE_ITEM deps ${Z_VCPKG_GN_NO_EXPORT}) # tbd: transitive deps
        foreach(dep IN LISTS deps)
            z_vcpkg_gn_get_cmake_target(cmake_dep "${dep}")
            message(STATUS "*** ${basename} -> ${dep} -> ${cmake_dep}")
            list(APPEND interface_link_targets "${cmake_dep}")
        endforeach()
        file(APPEND "${logfile}" "Installing: ${arg_INSTALL_DIR}/share/unofficial-${PORT}/${basename}-targets.cmake\n")
        configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-gn/unofficial-port-targets.cmake" "${arg_INSTALL_DIR}/share/unofficial-${PORT}/${basename}-targets.cmake" @ONLY)
        file(APPEND "${logfile}" "Installing: ${arg_INSTALL_DIR}/share/unofficial-${PORT}/${basename}-targets-${arg_BUILD_TYPE}.cmake\n")
        configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-gn/unofficial-port-targets-details.cmake" "${arg_INSTALL_DIR}/share/unofficial-${PORT}/${basename}-targets-${arg_BUILD_TYPE}.cmake" @ONLY)
    endforeach()

    # Main CMake config file
    file(APPEND "${logfile}" "Installing: ${arg_INSTALL_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake\n")
    configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-gn/unofficial-port-config.cmake" "${arg_INSTALL_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)
endfunction()

# A revised variant of vcpkg_gn_install
function(vcpkg_gn_export_cmake)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "DEFINITIONS_PATTERN" "TARGETS")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_gn_install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(auto_clean_debug_share TRUE)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_gn_export_cmake_build_type(
            BUILD_TYPE debug
            LABEL "${TARGET_TRIPLET}-dbg"
            INSTALL_DIR "${CURRENT_PACKAGES_DIR}/debug"
            DEFINITIONS_PATTERN "${arg_DEFINITIONS_PATTERN}"
            TARGETS ${arg_TARGETS}
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_gn_export_cmake_build_type(
            BUILD_TYPE release
            LABEL "${TARGET_TRIPLET}-rel"
            INSTALL_DIR "${CURRENT_PACKAGES_DIR}"
            DEFINITIONS_PATTERN "${arg_DEFINITIONS_PATTERN}"
            TARGETS ${arg_TARGETS}
        )
    endif()
endfunction()
