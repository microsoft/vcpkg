## # vcpkg_get_windows_sdk_path
##
## Get the Windows SDK installation path for a given SDK release.
##
## ## Usage
## ```cmake
## vcpkg_get_windows_sdk_path(
##     <${SDKPATH}> [<${SDKVERSION}>]
## )
## ```
## ## Parameters
## ### SDKPATH
## The variable where the Windows SDK path will be stored.
##
## ### SDKVERSION
## If specified, the function will search only for the given SDK version.
##
## ## Examples
##
## * [opengl](https://github.com/Microsoft/vcpkg/blob/master/ports/opengl/portfile.cmake)

function(vcpkg_get_windows_sdk_path SDKPATH)
    if(NOT ARGC EQUAL 2)
        set(SDKVERSION "")
    else()
        string(REGEX REPLACE "[^0-9\.]" "" SDKVERSION ${ARGV1})
    endif()

    if((NOT SDKVERSION) OR (SDKVERSION MATCHES "10."))
        get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot10]" ABSOLUTE CACHE)
        if(NOT TMPPATH)
            get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v10.0;InstallationFolder]" ABSOLUTE CACHE)
            if(NOT TMPPATH)
                get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v10.0;InstallationFolder]" ABSOLUTE CACHE)
            endif()
        endif()
    endif()
    if(((NOT TMPPATH) AND (NOT SDKVERSION)) OR (SDKVERSION MATCHES "8.1"))
        get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot81]" ABSOLUTE CACHE)
        if(NOT TMPPATH)
            get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v8.1;InstallationFolder]" ABSOLUTE CACHE)
            if(NOT TMPPATH)
                get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v8.1;InstallationFolder]" ABSOLUTE CACHE)
            endif()
        endif()
    endif()
    if(((NOT TMPPATH) AND (NOT SDKVERSION)) OR (SDKVERSION MATCHES "8.0"))
        get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot]" ABSOLUTE CACHE)
        if(NOT TMPPATH)
            get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v8.0;InstallationFolder]" ABSOLUTE CACHE)
            if(NOT TMPPATH)
                get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v8.0;InstallationFolder]" ABSOLUTE CACHE)
            endif()
        endif()
    endif()
    if(((NOT TMPPATH) AND (NOT SDKVERSION)) OR (SDKVERSION MATCHES "7.1"))
        get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v7.1;InstallationFolder]" ABSOLUTE CACHE)
        if(NOT TMPPATH)
            get_filename_component(TMPPATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v7.1;InstallationFolder]" ABSOLUTE CACHE)
        endif()
    endif()

    set(${SDKPATH} "${TMPPATH}" PARENT_SCOPE)
endfunction()
