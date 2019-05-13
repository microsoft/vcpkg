function(add_library name)
    _add_library(${ARGV})
    list(FIND ARGV "IMPORTED" IMPORTED_IDX)
    list(FIND ARGV "INTERFACE" INTERFACE_IDX)
    list(FIND ARGV "ALIAS" ALIAS_IDX)
    if(IMPORTED_IDX EQUAL -1 AND INTERFACE_IDX EQUAL -1 AND ALIAS_IDX EQUAL -1)
        get_target_property(IS_LIBRARY_SHARED ${name} TYPE)
        if(VCPKG_APPLOCAL_DEPS AND _VCPKG_TARGET_TRIPLET_PLAT MATCHES "windows|uwp" AND (IS_LIBRARY_SHARED STREQUAL "SHARED_LIBRARY" OR IS_LIBRARY_SHARED STREQUAL "MODULE_LIBRARY"))
            add_custom_command(TARGET ${name} POST_BUILD
                COMMAND powershell -noprofile -executionpolicy Bypass -file ${_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1
                    -targetBinary $<TARGET_FILE:${name}>
                    -installedDir "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin"
                    -OutVariable out
            )
        endif()
        set_target_properties(${name} PROPERTIES VS_USER_PROPS do_not_import_user.props)
        set_target_properties(${name} PROPERTIES VS_GLOBAL_VcpkgEnabled false)
    endif()
endfunction()