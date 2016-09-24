if(NOT VCPKG_TOOLCHAIN)
    if(CMAKE_GENERATOR_PLATFORM MATCHES "^[Ww][Ii][Nn]32$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Xx]64$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$")
        set(_VCPKG_TARGET_TRIPLET_ARCH arm)
    else()
        if(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 Win64$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 ARM$")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm)
        else()
            set(_VCPKG_TARGET_TRIPLET_ARCH x86)
        endif()
    endif()

    if(WINDOWS_STORE OR WINDOWS_PHONE)
        set(_VCPKG_TARGET_TRIPLET_PLAT uwp)
    else()
        set(_VCPKG_TARGET_TRIPLET_PLAT windows)
    endif()

    set(_VCPKG_TARGET_TRIPLET ${_VCPKG_TARGET_TRIPLET_ARCH}-${_VCPKG_TARGET_TRIPLET_PLAT})
    set(_VCPKG_INSTALLED_DIR ${CMAKE_CURRENT_LIST_DIR}/../../installed)
    set(_VCPKG_TOOLCHAIN_DIR ${CMAKE_CURRENT_LIST_DIR})

    if(CMAKE_BUILD_TYPE MATCHES "^Debug$" OR NOT DEFINED CMAKE_BUILD_TYPE)
        list(APPEND CMAKE_PREFIX_PATH
            ${_VCPKG_INSTALLED_DIR}/${_VCPKG_TARGET_TRIPLET}/debug
        )
    endif()
    list(APPEND CMAKE_PREFIX_PATH
        ${_VCPKG_INSTALLED_DIR}/${_VCPKG_TARGET_TRIPLET}
    )

    include_directories(${_VCPKG_INSTALLED_DIR}/${_VCPKG_TARGET_TRIPLET}/include)

    option(OVERRIDE_ADD_EXECUTABLE "Automatically copy dependencies into the output directory for executables." ON)
    if(OVERRIDE_ADD_EXECUTABLE)
        function(add_executable name)
            _add_executable(${ARGV})
            add_custom_command(TARGET ${name} POST_BUILD
                COMMAND powershell -executionpolicy UnRestricted -file ${_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1
                    -targetBinary $<TARGET_FILE:${name}>
                    -installedDir "${_VCPKG_INSTALLED_DIR}/${_VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin"
                    -OutVariable out
            )
        endfunction()
    endif()
    set(VCPKG_TOOLCHAIN ON)
endif()
