if(NOT _VCPKG_IOS_TOOLCHAIN)
    set(_VCPKG_IOS_TOOLCHAIN 1)

    if(POLICY CMP0056)
        cmake_policy(SET CMP0056 NEW)
    endif()
    if(POLICY CMP0066)
        cmake_policy(SET CMP0066 NEW)
    endif()
    if(POLICY CMP0067)
        cmake_policy(SET CMP0067 NEW)
    endif()
    if(POLICY CMP0137)
        cmake_policy(SET CMP0137 NEW)
    endif()
    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        VCPKG_CRT_LINKAGE VCPKG_TARGET_ARCHITECTURE
        VCPKG_C_FLAGS VCPKG_CXX_FLAGS
        VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
        VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
        VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
    )

    # Set the CMAKE_SYSTEM_NAME for try_compile calls.
    set(CMAKE_SYSTEM_NAME iOS CACHE STRING "")

    macro(_vcpkg_setup_ios_arch arch)
        unset(_vcpkg_ios_system_processor)
        unset(_vcpkg_ios_sysroot)
        unset(_vcpkg_ios_target_architecture)

        if ("${arch}" STREQUAL "arm64")
            set(_vcpkg_ios_system_processor "aarch64")
            set(_vcpkg_ios_target_architecture "arm64")
        elseif("${arch}" STREQUAL "arm64_32")
            set(_vcpkg_ios_system_processor "aarch64")
            set(_vcpkg_ios_target_architecture "arm64_32")
        elseif("${arch}" STREQUAL "arm")
            set(_vcpkg_ios_system_processor "arm")
            set(_vcpkg_ios_target_architecture "armv7")
        elseif("${arch}" STREQUAL "armv7k")
            set(_vcpkg_ios_system_processor "arm")
            set(_vcpkg_ios_target_architecture "armv7k")
        elseif("${arch}" STREQUAL "x64")
            set(_vcpkg_ios_system_processor "x86_64")
            set(_vcpkg_ios_sysroot "iphonesimulator")
            set(_vcpkg_ios_target_architecture "x86_64")
        elseif("${arch}" STREQUAL "x86")
            set(_vcpkg_ios_system_processor "i386")
            set(_vcpkg_ios_sysroot "iphonesimulator")
            set(_vcpkg_ios_target_architecture "i386")
        else()
            message(FATAL_ERROR
                    "Unknown VCPKG_TARGET_ARCHITECTURE value provided for triplet ${VCPKG_TARGET_TRIPLET}: ${arch}")
        endif()
    endmacro()

    _vcpkg_setup_ios_arch("${VCPKG_TARGET_ARCHITECTURE}")
    if(_vcpkg_ios_system_processor AND NOT CMAKE_SYSTEM_PROCESSOR)
        set(CMAKE_SYSTEM_PROCESSOR ${_vcpkg_ios_system_processor})
    endif()

    # If VCPKG_OSX_ARCHITECTURES or VCPKG_OSX_SYSROOT is set in the triplet, they will take priority,
    # so the following will be no-ops.
    set(CMAKE_OSX_ARCHITECTURES "${_vcpkg_ios_target_architecture}" CACHE STRING "Build architectures for iOS")
    if(_vcpkg_ios_sysroot)
        set(CMAKE_OSX_SYSROOT ${_vcpkg_ios_sysroot} CACHE STRING "iOS sysroot")
    endif()

    string(APPEND CMAKE_C_FLAGS_INIT " -fPIC ${VCPKG_C_FLAGS} ")
    string(APPEND CMAKE_CXX_FLAGS_INIT " -fPIC ${VCPKG_CXX_FLAGS} ")
    string(APPEND CMAKE_C_FLAGS_DEBUG_INIT " ${VCPKG_C_FLAGS_DEBUG} ")
    string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT " ${VCPKG_CXX_FLAGS_DEBUG} ")
    string(APPEND CMAKE_C_FLAGS_RELEASE_INIT " ${VCPKG_C_FLAGS_RELEASE} ")
    string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " ${VCPKG_CXX_FLAGS_RELEASE} ")

    string(APPEND CMAKE_MODULE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
endif()
