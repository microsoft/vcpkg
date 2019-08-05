option(VCPKG_APPLOCAL_DEPS "Automatically copy dependencies into the output directory for executables." ON)

vcpkg_define_function_overwrite_option(add_executable)

if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsPhone")
    set(_VCPKG_TARGET_TRIPLET_PLAT uwp)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))
    set(_VCPKG_TARGET_TRIPLET_PLAT linux)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"))
    set(_VCPKG_TARGET_TRIPLET_PLAT osx)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
    set(_VCPKG_TARGET_TRIPLET_PLAT windows)
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD"))
    set(_VCPKG_TARGET_TRIPLET_PLAT freebsd)
endif()

function(vcpkg_add_executable name)
    _add_executable(${ARGV})

    list(FIND ARGV "IMPORTED" IMPORTED_IDX)
    list(FIND ARGV "ALIAS" ALIAS_IDX)
    list(FIND ARGV "MACOSX_BUNDLE" MACOSX_BUNDLE_IDX)
    if(IMPORTED_IDX EQUAL -1 AND ALIAS_IDX EQUAL -1)
        if(VCPKG_APPLOCAL_DEPS)    
            if(_VCPKG_TARGET_TRIPLET_PLAT MATCHES "windows|uwp")
                add_custom_command(TARGET ${name} POST_BUILD
                    COMMAND powershell -noprofile -executionpolicy Bypass -file ${_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1
                        -targetBinary $<TARGET_FILE:${name}>
                        -installedDir "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin"
                        -OutVariable out
                )
            elseif(_VCPKG_TARGET_TRIPLET_PLAT MATCHES "osx")
                if (NOT MACOSX_BUNDLE_IDX EQUAL -1)
                    add_custom_command(TARGET ${name} POST_BUILD
                    COMMAND python ${_VCPKG_TOOLCHAIN_DIR}/osx/applocal.py
                        $<TARGET_FILE:${name}>
                        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>"
                    )
                endif()
            endif()
        endif()
        set_target_properties(${name} PROPERTIES VS_USER_PROPS do_not_import_user.props)
        set_target_properties(${name} PROPERTIES VS_GLOBAL_VcpkgEnabled false)
    endif()
endfunction()

if(VCPKG_ENABLE_add_executable)
    function(add_executable name)
        vcpkg_enable_function_overwrite_guard(add_executable "")
        vcpkg_add_executable(${ARGV})
        vcpkg_disable_function_overwrite_guard(add_executable "")
    endfunction()
endif()