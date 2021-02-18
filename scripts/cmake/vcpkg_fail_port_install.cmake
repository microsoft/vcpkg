#[===[.md:
# vcpkg_fail_port_install

Checks common requirements and fails the current portfile with a (default) error message

## Usage
```cmake
vcpkg_fail_port_install(
    [ALWAYS]
    [MESSAGE <"Reason for failure">]
    [ON_TARGET <Windows> [<OSX> ...]]
    [ON_ARCH <x64> [<arm> ...]]
    [ON_CRT_LINKAGE <static> [<dynamic> ...]])
    [ON_LIBRARY_LINKAGE <static> [<dynamic> ...]]
)
```

## Parameters
### MESSAGE
Additional failure message. If none is given, a default message will be displayed depending on the failure condition.

### ALWAYS
Will always fail early

### ON_TARGET
Targets for which the build should fail early. Valid targets are `<target>` from `VCPKG_IS_TARGET_<target>` (see `vcpkg_common_definitions.cmake`).

### ON_ARCH
Architecture for which the build should fail early.

### ON_CRT_LINKAGE
CRT linkage for which the build should fail early.

### ON_LIBRARY_LINKAGE
Library linkage for which the build should fail early.

## Examples

* [aws-lambda-cpp](https://github.com/Microsoft/vcpkg/blob/master/ports/aws-lambda-cpp/portfile.cmake)
#]===]

function(vcpkg_fail_port_install)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _csc "ALWAYS" "MESSAGE" "ON_TARGET;ON_ARCH;ON_CRT_LINKAGE;ON_LIBRARY_LINKAGE")
    if(DEFINED _csc_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown arguments passed to vcpkg_fail_port_install. Please correct the portfile!")
    endif()
    if(DEFINED _csc_MESSAGE)
        set(_csc_MESSAGE "${_csc_MESSAGE}\n")
    else()
        set(_csc_MESSAGE "")
    endif()

    unset(_fail_port)
    #Target fail check
    if(DEFINED _csc_ON_TARGET)
        foreach(_target ${_csc_ON_TARGET})
            string(TOUPPER ${_target} _target_upper)
            if(VCPKG_TARGET_IS_${_target_upper})
                set(_fail_port TRUE)
                set(_csc_MESSAGE "${_csc_MESSAGE}Target '${_target}' not supported by ${PORT}!\n")
            endif()
        endforeach()
    endif()

    #Architecture fail check
    if(DEFINED _csc_ON_ARCH)
        foreach(_arch ${_csc_ON_ARCH})
            if(${VCPKG_TARGET_ARCHITECTURE} MATCHES ${_arch})
                set(_fail_port TRUE)
                set(_csc_MESSAGE "${_csc_MESSAGE}Architecture '${_arch}' not supported by ${PORT}!\n")
            endif()
        endforeach()
    endif()

    #CRT linkage fail check
    if(DEFINED _csc_ON_CRT_LINKAGE)
        foreach(_crt_link ${_csc_ON_CRT_LINKAGE})
            if("${VCPKG_CRT_LINKAGE}" MATCHES "${_crt_link}")
                set(_fail_port TRUE)
                set(_csc_MESSAGE "${_csc_MESSAGE}CRT linkage '${VCPKG_CRT_LINKAGE}' not supported by ${PORT}!\n")
            endif()
        endforeach()
    endif()

    #Library linkage fail check
        if(DEFINED _csc_ON_LIBRARY_LINKAGE)
        foreach(_lib_link ${_csc_ON_LIBRARY_LINKAGE})
            if("${VCPKG_LIBRARY_LINKAGE}" MATCHES "${_lib_link}")
                set(_fail_port TRUE)
                set(_csc_MESSAGE "${_csc_MESSAGE}Library linkage '${VCPKG_LIBRARY_LINKAGE}' not supported by ${PORT}!\n")
            endif()
        endforeach()
    endif()

    if(_fail_port OR _csc_ALWAYS)
        message(FATAL_ERROR ${_csc_MESSAGE})
    endif()
endfunction()
