option(VCPKG_ENABLE_ADD_LIBRARY "Enables override of the cmake function add_library." ON)
mark_as_advanced(VCPKG_ENABLE_ADD_LIBRARY)
CMAKE_DEPENDENT_OPTION(VCPKG_ENABLE_ADD_LIBRARY_EXTERNAL_OVERRIDE "Tells VCPKG to use _add_library instead of add_library." OFF "NOT VCPKG_ENABLE_ADD_LIBRARY" OFF)
mark_as_advanced(VCPKG_ENABLE_ADD_LIBRARY_EXTERNAL_OVERRIDE)

function(vcpkg_add_library name)
    if(VCPKG_ENABLE_ADD_LIBRARY OR VCPKG_ENABLE_ADD_LIBRARY_EXTERNAL_OVERRIDE)
        _add_library(${ARGV})
    else()
        add_library(${ARGV})
    endif()
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

if(VCPKG_ENABLE_ADD_LIBRARY)
    function(add_library name)
        if(DEFINED _vcpkg_add_library_guard)
            vcpkg_msg(FATAL_ERROR "add_library" "INFINIT LOOP DETECT. Guard _vcpkg_add_library_guard. Did you supply your own add_library override? \n \
                                    If yes: please set VCPKG_ENABLE_ADD_LIBRARY off and call vcpkg_add_library if you want to have vcpkg corrected behavior. \n \
                                    If no: please open an issue on GITHUB describe the fail case!" ALWAYS)
        else()
            set(_vcpkg_add_library_guard ON)
        endif()
        vcpkg_add_library(${ARGV})
        unset(_vcpkg_add_library_guard)
    endfunction()
endif()