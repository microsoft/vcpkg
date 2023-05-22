# Verifies the PhysX SDK installation and finds libraries and headers
set(OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib")
set(OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")

# Set defaults according to known triplets

if(VCPKG_TARGET_TRIPLET STREQUAL x64-windows)
    if(NOT DEFINED VCPKG_LIBRARY_LINKAGE)
        set(VCPKG_LIBRARY_LINKAGE dynamic)
    endif()
    if(NOT DEFINED VCPKG_CRT_LINKAGE)
        set(VCPKG_CRT_LINKAGE dynamic)
    endif()
elseif(VCPKG_TARGET_TRIPLET MATCHES x64-windows-static)
    if(NOT DEFINED VCPKG_LIBRARY_LINKAGE)
        set(VCPKG_LIBRARY_LINKAGE static)
    endif()
    if(NOT DEFINED VCPKG_CRT_LINKAGE)
            set(VCPKG_CRT_LINKAGE static)
    endif()

    if(VCPKG_TARGET_TRIPLET STREQUAL x64-windows-static-md)
        if(NOT DEFINED VCPKG_CRT_LINKAGE)
            set(VCPKG_CRT_LINKAGE dynamic)
        endif()
    endif()
elseif(VCPKG_TARGET_TRIPLET STREQUAL x64-linux)
    if(NOT DEFINED VCPKG_LIBRARY_LINKAGE)
        set(VCPKG_LIBRARY_LINKAGE static)
    endif()
elseif(VCPKG_TARGET_TRIPLET STREQUAL x64-linux-dynamic)
    if(NOT DEFINED VCPKG_LIBRARY_LINKAGE)
        set(VCPKG_LIBRARY_LINKAGE dynamic)
    endif()
elseif(VCPKG_TARGET_TRIPLET STREQUAL arm64-linux)
    if(NOT DEFINED VCPKG_LIBRARY_LINKAGE)
        set(VCPKG_LIBRARY_LINKAGE static)
    endif()
endif()

find_path(OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS NAMES PxPhysics.h PATHS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/physx" NO_DEFAULT_PATH)
if (WIN32)
    # Note: Omniverse PhysX SDK no longer supports 32 bit
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE NAMES PhysX_static_64 PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
        find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG   NAMES PhysX_static_64 PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE NAMES PhysX_64 PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
        find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG   NAMES PhysX_64 PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
    else()
        message(FATAL_ERROR "Unrecognized VCPKG_LIBRARY_LINKAGE: ${VCPKG_LIBRARY_LINKAGE} (valid are 'static' and 'dynamic')")
    endif()
elseif(UNIX)
    find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE NAMES PhysX_static_64 PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
    find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG   NAMES PhysX_static_64 PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
endif()

# message(WARNING "PHYSX_INCLUDE_DIRS: ${PHYSX_INCLUDE_DIRS}")
# message(WARNING "PHYSX_LIBRARY_RELEASE: ${PHYSX_LIBRARY_RELEASE}")
# message(WARNING "PHYSX_LIBRARY_DEBUG: ${PHYSX_LIBRARY_DEBUG}")

if(NOT OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS OR NOT (OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE OR OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG))
    message(FATAL_ERROR "Broken installation of vcpkg port for PhysX (include or libs not found)")
endif()

set(OMNIVERSE-PHYSX-SDK_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE})
if(OMNIVERSE-PHYSX-SDK_LIBRARY_LINKAGE STREQUAL "")
    message(WARNING "Could not infer library linkage from triplet")
endif()
if (WIN32)
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    message(WARNING "---------------- YEAH GOING FOR DYNAMIC CRT!")
        set(OMNIVERSE-PHYSX-SDK_CRT_LINKAGE "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(WARNING "---------------- YEAH GOING FOR STATIC CRT!")
        set(OMNIVERSE-PHYSX-SDK_CRT_LINKAGE "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    else()
        message(WARNING "Could not infer CRT linkage from triplet")
    endif()
endif()

if (WIN32)
    if (OMNIVERSE-PHYSX-SDK_LIBRARY_LINKAGE STREQUAL dynamic)
    message(WARNING "---------------- YEAH GOING FOR DYNAMIC LIBS!")
        set(OMNIVERSE-PHYSX-SDK_LIBRARIES
            "PhysXExtensions_static_64.lib"
            "PhysX_64.lib"
            "PhysXPvdSDK_static_64.lib"
            "PhysXCharacterKinematic_static_64.lib"
            "PhysXCooking_64.lib"
            "PhysXCommon_64.lib"
            "PhysXFoundation_64.lib"
            "PhysXVehicle_static_64.lib"
            "PhysXVehicle2_static_64.lib"
        )
    else()
        message(WARNING "---------------- YEAH GOING FOR STATIC LIBS!")
        set(OMNIVERSE-PHYSX-SDK_LIBRARIES
            "PhysXExtensions_static_64.lib"
            "PhysX_static_64.lib"
            "PhysXPvdSDK_static_64.lib"
            "PhysXCharacterKinematic_static_64.lib"
            "PhysXCooking_static_64.lib"
            "PhysXCommon_static_64.lib"
            "PhysXFoundation_static_64.lib"
            "PhysXVehicle_static_64.lib"
            "PhysXVehicle2_static_64.lib"
        )
    endif()
    # Make sure the next CMake targets after this file will have the correct multi-threaded
    # statically-linked runtime library (either debug or release) as required by PhysX
    # message("Setting CMAKE_MSVC_RUNTIME_LIBRARY to multi-threaded statically-linked runtime for next targets")
    # set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
elseif(UNIX)
    set(OMNIVERSE-PHYSX-SDK_LIBRARIES
        "PhysXExtensions_static_64"
        "PhysX_static_64"
        "PhysXPvdSDK_static_64"
        "PhysXCharacterKinematic_static_64"
        "PhysXCooking_static_64"
        "PhysXCommon_static_64"
        "PhysXFoundation_static_64"
        "PhysXVehicle_static_64"
    )
endif()

set(OMNIVERSE-PHYSX-SDK_FOUND true)


