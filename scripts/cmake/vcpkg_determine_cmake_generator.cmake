function(vcpkg_is_ninja_useable OUTPUT_NINJA_USEABLE)
    if(CMAKE_HOST_WIN32)
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432} AND NOT DEFINED VCPKG_HOST_ARCHITECTURE)
            set(VCPKG_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
        else()
            set(VCPKG_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
        endif()
    endif()
    if(VCPKG_HOST_ARCHITECTURE STREQUAL "x86")
        # Prebuilt ninja binaries are only provided for x64 hosts
        set(OUTPUT_NINJA_USEABLE OFF PARENT_SCOPE)
    elseif(VCPKG_TARGET_IS_UWP)
        # Ninja and MSBuild have many differences when targetting UWP, so use MSBuild to maximize existing compatibility
        set(OUTPUT_NINJA_USEABLE OFF PARENT_SCOPE)
    else()
      set(OUTPUT_NINJA_USEABLE ON PARENT_SCOPE)
    endif()
endfunction()

## # vcpkg_determine_cmake_generator
##
## Automatically determines the cmake generator to use
##
## ## Usage
## ```cmake
## vcpkg_determine_cmake_generator(OUTPUT_GENERATOR)
## ```
##
function(vcpkg_determine_cmake_generator OUTPUT_GENERATOR)
    cmake_parse_arguments(_dcg 
        "PREFER_NINJA"
        ""
        ""
        ${ARGN}
    )
    vcpkg_is_ninja_useable(NINJA_USEABLE)
    
 
    if(NOT DEFINED VCPKG_USE_NINJA)
        set(VCPKG_USE_NINJA ${NINJA_USEABLE}) # Ninja as generator
    endif()
    
    if(_dcg_PREFER_NINJA AND VCPKG_USE_NINJA) #Use Ninja for Windows targets if possible. 
        set(${OUTPUT_GENERATOR} "Ninja" PARENT_SCOPE)
    elseif(VCPKG_CHAINLOAD_TOOLCHAIN_FILE OR NOT VCPKG_TARGET_IS_WINDOWS) #Use Ninja for everything which is not Windows. 
        set(${OUTPUT_GENERATOR} "Ninja" PARENT_SCOPE)
    else() # Use Visual Studio Generators. 
        if(NOT VCPKG_CMAKE_VS_GENERATOR)
            message(STATUS "CMAKE VS Generator not set: ${VCPKG_CMAKE_VS_GENERATOR}")
            message(FATAL_ERROR "Unable to determine appropriate generator for triplet ${TARGET_TRIPLET}: ${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}-${VCPKG_PLATFORM_TOOLSET}")
        endif()
        #message(STATUS "Using CMAKE VS Generator: ${VCPKG_CMAKE_VS_GENERATOR}")
        set(${OUTPUT_GENERATOR} "${VCPKG_CMAKE_VS_GENERATOR}" PARENT_SCOPE)
    endif()
    
endfunction()
