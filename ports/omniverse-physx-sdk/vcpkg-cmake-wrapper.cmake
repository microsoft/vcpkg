# # Verifies the PhysX SDK installation and finds libraries and headers
# set(PHYSX_RELEASE_LIBS_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib")
# set(PHYSX_DEBUG_LIBS_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")

# find_path(PHYSX_INCLUDE_DIRS NAMES PxPhysics.h PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/physx" NO_DEFAULT_PATH)
# if (WIN32)
#     find_library(PHYSX_LIBRARY_RELEASE NAMES PhysX_64 PhysX_32 PATHS "${PHYSX_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
#     find_library(PHYSX_LIBRARY_DEBUG   NAMES PhysX_64 PhysX_32 PATHS "${PHYSX_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
# elseif(UNIX)
#     find_library(PHYSX_LIBRARY_RELEASE NAMES PhysX_static_64 PATHS "${PHYSX_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
#     find_library(PHYSX_LIBRARY_DEBUG   NAMES PhysX_static_64 PATHS "${PHYSX_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
# endif()
# if(NOT PHYSX_INCLUDE_DIRS OR NOT (PHYSX_LIBRARY_RELEASE OR PHYSX_LIBRARY_DEBUG))
#     message(FATAL_ERROR "Broken installation of vcpkg port for PhysX")
# endif()

# if (WIN32)
#     if (PHYSX_LIBRARY_RELEASE MATCHES PhysX_64.lib)
#         set(PLATFORM_BITS 64)
#     else()
#         set(PLATFORM_BITS 32)
#     endif()
# endif()

# if (WIN32)
#     set(PHYSX_LIBRARIES
#         "PhysXExtensions_static_${PLATFORM_BITS}.lib"
#         "PhysX_${PLATFORM_BITS}.lib"
#         "PhysXPvdSDK_static_${PLATFORM_BITS}.lib"
#         "PhysXCharacterKinematic_static_${PLATFORM_BITS}.lib"
#         "PhysXCooking_${PLATFORM_BITS}.lib"
#         "PhysXCommon_${PLATFORM_BITS}.lib"
#         "PhysXFoundation_${PLATFORM_BITS}.lib"
#         "PhysXVehicle_static_${PLATFORM_BITS}.lib"
#     )
#     # Make sure the next CMake targets after this file will have the correct multi-threaded
#     # statically-linked runtime library (either debug or release) as required by PhysX
#     message("Setting CMAKE_MSVC_RUNTIME_LIBRARY to multi-threaded statically-linked runtime for next targets")
#     set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
# elseif(UNIX)
#     set(PHYSX_LIBRARIES
#         "PhysXExtensions_static_64"
#         "PhysX_static_64"
#         "PhysXPvdSDK_static_64"
#         "PhysXCharacterKinematic_static_64"
#         "PhysXCooking_static_64"
#         "PhysXCommon_static_64"
#         "PhysXFoundation_static_64"
#         "PhysXVehicle_static_64"
#     )
# endif()

# set(PHYSX_FOUND true)

# message(FATAL_ERROR "YEAH EXECUTING WRAPPER")

# Verifies the PhysX SDK installation and finds libraries and headers
set(PHYSX_RELEASE_LIBS_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib")
set(PHYSX_DEBUG_LIBS_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")

find_path(PHYSX_INCLUDE_DIRS NAMES PxPhysics.h PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/physx" NO_DEFAULT_PATH)
if (WIN32)
    find_library(PHYSX_LIBRARY_RELEASE NAMES PhysX_64 PhysX_32 PATHS "${PHYSX_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
    find_library(PHYSX_LIBRARY_DEBUG   NAMES PhysX_64 PhysX_32 PATHS "${PHYSX_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
elseif(UNIX)
    find_library(PHYSX_LIBRARY_RELEASE NAMES PhysX_static_64 PATHS "${PHYSX_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
    find_library(PHYSX_LIBRARY_DEBUG   NAMES PhysX_static_64 PATHS "${PHYSX_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
endif()
if(NOT PHYSX_INCLUDE_DIRS OR NOT (PHYSX_LIBRARY_RELEASE OR PHYSX_LIBRARY_DEBUG))
    message(FATAL_ERROR "Broken installation of vcpkg port for PhysX")
endif()

if (WIN32)
    if (PHYSX_LIBRARY_RELEASE MATCHES PhysX_64.lib)
        set(PLATFORM_BITS 64)
    else()
        set(PLATFORM_BITS 32)
    endif()
endif()

if (WIN32)
    set(PHYSX_LIBRARIES
        "PhysXExtensions_static_${PLATFORM_BITS}.lib"
        "PhysX_${PLATFORM_BITS}.lib"
        "PhysXPvdSDK_static_${PLATFORM_BITS}.lib"
        "PhysXCharacterKinematic_static_${PLATFORM_BITS}.lib"
        "PhysXCooking_${PLATFORM_BITS}.lib"
        "PhysXCommon_${PLATFORM_BITS}.lib"
        "PhysXFoundation_${PLATFORM_BITS}.lib"
        "PhysXVehicle_static_${PLATFORM_BITS}.lib"
    )
    # Make sure the next CMake targets after this file will have the correct multi-threaded
    # statically-linked runtime library (either debug or release) as required by PhysX
    message("Setting CMAKE_MSVC_RUNTIME_LIBRARY to multi-threaded statically-linked runtime for next targets")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
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


