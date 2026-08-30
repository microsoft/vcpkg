function(z_vcpkg_setup_pkgconfig_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "CONFIG" "")

    if("${arg_CONFIG}" STREQUAL "")
        message(FATAL_ERROR "CONFIG is required.")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(envvar IN ITEMS PKG_CONFIG PKG_CONFIG_PATH)
        if(DEFINED ENV{${envvar}})
            set("z_vcpkg_env_backup_${envvar}" "$ENV{${envvar}}" PARENT_SCOPE)
        else()
            unset("z_vcpkg_env_backup_${envvar}" PARENT_SCOPE)
        endif()
    endforeach()

    vcpkg_find_acquire_program(PKGCONFIG)
    cmake_path(GET PKGCONFIG PARENT_PATH pkgconfig_path)
    string(FIND "${pkgconfig_path}" "${DOWNLOADS}/tools/" index)
    if(PKGCONFIG MATCHES " " AND index EQUAL "0")
        # *** Keep this in sync with ports/vcpkg-make/vcpkg_scripts.cmake ***
        # autotools builds may stumble over space in ENV{PKG_CONFIG}.
        # Unfortunately, the unpacked pkgconf 3.0.6 MSI has this property.
        # Mitigate by creating a sufficiently unique name to be found robustly via PATH
        # despite the presence of the incompatible msys /usr/bin/pkgconf.exe.
        # However, we can leave PKGCONFIG unchanged.
        cmake_path(GET PKGCONFIG FILENAME pkgconfig_filename)
        set(vcpkg_pkgconfig_filename "vcpkg-${pkgconfig_filename}")
        set(vcpkg_pkgconfig_filepath "${pkgconfig_path}/${vcpkg_pkgconfig_filename}")
        if(NOT EXISTS "${vcpkg_pkgconfig_filepath}")
            file(COPY_FILE "${PKGCONFIG}" "${vcpkg_pkgconfig_filepath}")
        endif()
        set(ENV{PKG_CONFIG} "${vcpkg_pkgconfig_filename}")
    else()
        set(ENV{PKG_CONFIG} "${PKGCONFIG}")
    endif()

    cmake_path(CONVERT "${pkgconfig_path}" TO_CMAKE_PATH_LIST pkgconfig_path NORMALIZE)
    cmake_path(CONVERT "$ENV{PATH}" TO_CMAKE_PATH_LIST path_list NORMALIZE)
    if(NOT "${pkgconfig_path}" IN_LIST path_list)
        vcpkg_add_to_path("${pkgconfig_path}")
    endif()

    foreach(prefix IN ITEMS "${CURRENT_INSTALLED_DIR}" "${CURRENT_PACKAGES_DIR}")
        if(EXISTS "${prefix}/share/pkgconfig")
            vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${prefix}/share/pkgconfig")
        endif()
        if(arg_CONFIG STREQUAL "RELEASE")
            if(EXISTS "${prefix}/lib/pkgconfig")
                vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${prefix}/lib/pkgconfig")
                # search order is lib, share, external
            endif()
        elseif(arg_CONFIG STREQUAL "DEBUG")
            if(EXISTS "${prefix}/debug/lib/pkgconfig")
                vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${prefix}/debug/lib/pkgconfig")
                # search order is debug/lib, share, external
            endif()
        else()
            message(FATAL_ERROR "CONFIG must be either RELEASE or DEBUG.")
        endif()
    endforeach()
    # total search order is current packages dir, current installed dir, external
endfunction()

function(z_vcpkg_restore_pkgconfig_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(envvar IN ITEMS PKG_CONFIG PKG_CONFIG_PATH)
        if(DEFINED z_vcpkg_env_backup_${envvar})
            set("ENV{${envvar}}" "${z_vcpkg_env_backup_${envvar}}")
        else()
            unset("ENV{${envvar}}")
        endif()
    endforeach()
endfunction()
