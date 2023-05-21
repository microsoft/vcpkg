# Verifies the PhysX SDK installation and finds libraries and headers
set(PHYSX_RELEASE_LIBS_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib")
set(PHYSX_DEBUG_LIBS_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")

find_path(PHYSX_INCLUDE_DIRS NAMES PxPhysics.h PATHS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/physx" NO_DEFAULT_PATH)
if (WIN32)
    # Note: Omniverse PhysX SDK no longer supports 32 bit
    find_library(PHYSX_LIBRARY_RELEASE NAMES PhysX_64 PhysX_static_64 PATHS "${PHYSX_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
    find_library(PHYSX_LIBRARY_DEBUG   NAMES PhysX_64 PhysX_static_64 PATHS "${PHYSX_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
elseif(UNIX)
    find_library(PHYSX_LIBRARY_RELEASE NAMES PhysX_static_64 PATHS "${PHYSX_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
    find_library(PHYSX_LIBRARY_DEBUG   NAMES PhysX_static_64 PATHS "${PHYSX_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
endif()

# message(WARNING "PHYSX_INCLUDE_DIRS: ${PHYSX_INCLUDE_DIRS}")
# message(WARNING "PHYSX_LIBRARY_RELEASE: ${PHYSX_LIBRARY_RELEASE}")
# message(WARNING "PHYSX_LIBRARY_DEBUG: ${PHYSX_LIBRARY_DEBUG}")

if(NOT PHYSX_INCLUDE_DIRS OR NOT (PHYSX_LIBRARY_RELEASE OR PHYSX_LIBRARY_DEBUG))
    message(FATAL_ERROR "Broken installation of vcpkg port for PhysX (include or libs not found)")
endif()

if (WIN32)
    if (PHYSX_LIBRARY_RELEASE MATCHES PhysX_64.lib)
        set(PHYSX_LIBRARIES
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
        set(PHYSX_LIBRARIES
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
    set(PHYSX_LIBRARIES
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

set(PHYSX_FOUND true)


