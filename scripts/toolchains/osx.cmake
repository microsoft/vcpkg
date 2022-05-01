if(NOT _VCPKG_OSX_TOOLCHAIN)
    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES VCPKG_CRT_LINKAGE VCPKG_TARGET_ARCHITECTURE 
                                                     VCPKG_C_FLAGS VCPKG_CXX_FLAGS
                                                     VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
                                                     VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
                                                     VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
                                                     )
    set(_VCPKG_OSX_TOOLCHAIN 1)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
        set(CMAKE_SYSTEM_VERSION "${CMAKE_HOST_SYSTEM_VERSION}" CACHE STRING "")
    else()
        set(CMAKE_SYSTEM_VERSION "17.0.0" CACHE STRING "")
    endif()
    set(CMAKE_SYSTEM_NAME Darwin CACHE STRING "")

    set(CMAKE_MACOSX_RPATH ON CACHE BOOL "")

    if(NOT DEFINED CMAKE_SYSTEM_PROCESSOR)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
           set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
           set(CMAKE_SYSTEM_PROCESSOR x86 CACHE STRING "")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
           set(CMAKE_SYSTEM_PROCESSOR arm64 CACHE STRING "")
        else()
           set(CMAKE_SYSTEM_PROCESSOR "${CMAKE_HOST_SYSTEM_PROCESSOR}" CACHE STRING "")
        endif()
    endif()


    string(APPEND CMAKE_C_FLAGS_INIT " -fPIC ${VCPKG_C_FLAGS} ")
    string(APPEND CMAKE_CXX_FLAGS_INIT " -fPIC ${VCPKG_CXX_FLAGS} ")
    string(APPEND CMAKE_C_FLAGS_DEBUG_INIT " ${VCPKG_C_FLAGS_DEBUG} ")
    string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT " ${VCPKG_CXX_FLAGS_DEBUG} ")
    string(APPEND CMAKE_C_FLAGS_RELEASE_INIT " ${VCPKG_C_FLAGS_RELEASE} ")
    string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " ${VCPKG_CXX_FLAGS_RELEASE} ")

    string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")

endif()
