option(VCPKG_APPLOCAL_DEPS "Automatically copy dependencies into the output directory for executables." ON)

option(VCPKG_ENABLE_ADD_EXECUTABLE "Enables override of the cmake function add_executable." ON)
mark_as_advanced(VCPKG_ENABLE_ADD_EXECUTABLE)
CMAKE_DEPENDENT_OPTION(VCPKG_ADD_EXECUTABLE_EXTERNAL_OVERRIDE "Tells VCPKG to use _add_executable instead of add_executable." OFF "NOT VCPKG_ENABLE_ADD_EXECUTABLE" OFF)
mark_as_advanced(VCPKG_ADD_EXECUTABLE_EXTERNAL_OVERRIDE)

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
    if(VCPKG_ENABLE_ADD_EXECUTABLE OR VCPKG_ADD_EXECUTABLE_EXTERNAL_OVERRIDE)
        _add_executable(${ARGV})
    else()
        add_executable(${ARGV})
    endif()
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

if(VCPKG_ENABLE_ADD_EXECUTABLE)
    function(add_executable name)
        if(DEFINED _vcpkg_add_executable_guard)
            vcpkg_msg(FATAL_ERROR "add_executable" "INFINIT LOOP DETECTED. Guard _vcpkg_add_executable_guard. Did you supply your own add_executable override? \n \
                                    If yes: please set VCPKG_ENABLE_ADD_EXECUTABLE off and call vcpkg_add_executable if you want to have vcpkg corrected behavior. You might also want to check VCPKG_ADD_EXECUTABLE_EXTERNAL_OVERRIDE\n \
                                    If no: please open an issue on GITHUB describe the fail case!" ALWAYS)
        else()
            set(_vcpkg_add_executable_guard ON)
        endif()
        vcpkg_add_executable(${ARGV})
        unset(_vcpkg_add_executable_guard)
    endfunction()
endif()