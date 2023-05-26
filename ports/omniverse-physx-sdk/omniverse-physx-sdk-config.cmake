# omniverse-physx-sdk-config.cmake
# A user's CMakeLists.txt should:
#   find_package(omniverse-physx-sdk CONFIG REQUIRED)
#   target_link_libraries(main omniverse-physx-sdk)
# the GPU acceleration so/dlls are in the port's bin and debug/bin directories (needed for late binding)

# Find include and library directories (up one level multiple times)
get_filename_component(z_vcpkg_omniverse_physx_sdk_prefix "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(z_vcpkg_omniverse_physx_sdk_prefix "${z_vcpkg_omniverse_physx_sdk_prefix}" PATH)
get_filename_component(z_vcpkg_omniverse_physx_sdk_prefix "${z_vcpkg_omniverse_physx_sdk_prefix}" PATH)

get_filename_component(OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS "${z_vcpkg_omniverse_physx_sdk_prefix}/include/physx" ABSOLUTE)
get_filename_component(OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR "${z_vcpkg_omniverse_physx_sdk_prefix}/lib" ABSOLUTE)
get_filename_component(OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR "${z_vcpkg_omniverse_physx_sdk_prefix}/debug/lib" ABSOLUTE)
get_filename_component(OMNIVERSE-PHYSX-SDK_RELEASE_BIN_DIR "${z_vcpkg_omniverse_physx_sdk_prefix}/bin" ABSOLUTE)
get_filename_component(OMNIVERSE-PHYSX-SDK_DEBUG_BIN_DIR "${z_vcpkg_omniverse_physx_sdk_prefix}/debug/bin" ABSOLUTE)
get_filename_component(OMNIVERSE-PHYSX-SDK_RELEASE_TOOLS_DIR "${z_vcpkg_omniverse_physx_sdk_prefix}/tools" ABSOLUTE)
get_filename_component(OMNIVERSE-PHYSX-SDK_DEBUG_TOOLS_DIR "${z_vcpkg_omniverse_physx_sdk_prefix}/tools/debug" ABSOLUTE)

# Find main library files
find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE NAMES PhysX_static_64 PhysX_64 PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG NAMES PhysX_static_64 PhysX_64 PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)

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

# Finally create imported target
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    add_library(omniverse-physx-sdk STATIC IMPORTED)
else()
    add_library(omniverse-physx-sdk SHARED IMPORTED)
endif()

# Set IMPORTED_IMPLIB for the main target in case of dynamic libraries
if (WIN32 AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set_target_properties(omniverse-physx-sdk PROPERTIES
        IMPORTED_IMPLIB_RELEASE "${OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE}"
        IMPORTED_IMPLIB_DEBUG "${OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG}"
    )
endif()

set_target_properties(omniverse-physx-sdk PROPERTIES
    IMPORTED_LOCATION_RELEASE "${OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE}"
    IMPORTED_LOCATION_DEBUG "${OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG}"
    INTERFACE_INCLUDE_DIRECTORIES "${OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS}"
)

# Deal with requested CRT linkage
if(WIN32 AND VCPKG_CRT_LINKAGE STREQUAL "static")
    set_target_properties(omniverse-physx-sdk PROPERTIES
        INTERFACE_COMPILE_OPTIONS "/MT$<$<CONFIG:Debug>:d>"
    )
elseif(WIN32 AND VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set_target_properties(omniverse-physx-sdk PROPERTIES
        INTERFACE_COMPILE_OPTIONS "/MD$<$<CONFIG:Debug>:d>"
    )
endif()

# Get the necessary dependencies to link in
if (WIN32)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(OMNIVERSE-PHYSX-SDK_LIBRARIES
            "PhysXExtensions_static_64.lib"
            "PhysXPvdSDK_static_64.lib"
            "PhysXCharacterKinematic_static_64.lib"
            "PhysXCooking_64.lib"
            "PhysXCommon_64.lib"
            "PhysXFoundation_64.lib"
            "PhysXVehicle_static_64.lib"
            "PhysXVehicle2_static_64.lib"
        )
    else()
        set(OMNIVERSE-PHYSX-SDK_LIBRARIES
            "PhysXExtensions_static_64.lib"
            "PhysXPvdSDK_static_64.lib"
            "PhysXCharacterKinematic_static_64.lib"
            "PhysXCooking_static_64.lib"
            "PhysXCommon_static_64.lib"
            "PhysXFoundation_static_64.lib"
            "PhysXVehicle_static_64.lib"
            "PhysXVehicle2_static_64.lib"
        )
    endif()
elseif(UNIX)
    set(OMNIVERSE-PHYSX-SDK_LIBRARIES
        "PhysXExtensions_static_64"
        "PhysXPvdSDK_static_64"
        "PhysXCharacterKinematic_static_64"
        "PhysXCooking_static_64"
        "PhysXCommon_static_64"
        "PhysXFoundation_static_64"
        "PhysXVehicle_static_64"
    )
endif()

# Prepare the full paths of the libraries and add them to the target as dependencies
if (WIN32)
    foreach(lib ${OMNIVERSE-PHYSX-SDK_LIBRARIES})
        find_library(full_path_of_${lib}_RELEASE NAMES ${lib} PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
        find_library(full_path_of_${lib}_DEBUG NAMES ${lib} PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
        add_library(${lib} UNKNOWN IMPORTED)

        # Set IMPORTED_IMPLIB for dynamic libraries
        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            set_target_properties(${lib} PROPERTIES
                IMPORTED_IMPLIB_RELEASE "${full_path_of_${lib}_RELEASE}"
                IMPORTED_IMPLIB_DEBUG "${full_path_of_${lib}_DEBUG}"
            )
        endif()

        set_target_properties(${lib} PROPERTIES
            IMPORTED_LOCATION_RELEASE "${full_path_of_${lib}_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${full_path_of_${lib}_DEBUG}"
        )
        list(APPEND full_paths_of_libraries "${lib}")
    endforeach()
elseif(UNIX)
    foreach(lib ${OMNIVERSE-PHYSX-SDK_LIBRARIES})
        find_library(full_path_of_${lib}_RELEASE NAMES ${lib} PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
        find_library(full_path_of_${lib}_DEBUG NAMES ${lib} PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
        add_library(${lib} UNKNOWN IMPORTED)

        # When CMake will link against this lib target, it will use this absolute path
        set_target_properties(${lib} PROPERTIES
            IMPORTED_LOCATION_RELEASE "${full_path_of_${lib}_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${full_path_of_${lib}_DEBUG}"
        )
        list(APPEND full_paths_of_libraries "${lib}")
    endforeach()
endif()

# Link the libraries to the target with INTERFACE: i.e. whoever links with this target, will also link with all these libs, but the main library will NOT link against these (it doesn't depend on them).
target_link_libraries(omniverse-physx-sdk INTERFACE ${full_paths_of_libraries})

# Lastly also provide a target for clients to link with the GPU library (optional, provided by NVIDIA and downloaded through packman)

# Find GPU library files
if(WIN32)
    find_library(OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_RELEASE NAMES PhysXGpu_64.dll PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_TOOLS_DIR}" NO_DEFAULT_PATH)
    find_library(OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_DEBUG NAMES PhysXGpu_64.dll PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_TOOLS_DIR}" NO_DEFAULT_PATH)
elseif(UNIX)
    find_library(OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_RELEASE NAMES PhysXGpu_64 PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_TOOLS_DIR}" NO_DEFAULT_PATH)
    find_library(OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_DEBUG NAMES PhysXGpu_64 PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_TOOLS_DIR}" NO_DEFAULT_PATH)
endif()


# Create imported target for GPU library
add_library(omniverse-physx-sdk-gpu-library SHARED IMPORTED)

set_target_properties(omniverse-physx-sdk-gpu-library PROPERTIES
    IMPORTED_LOCATION_RELEASE "${OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_RELEASE}"
    IMPORTED_LOCATION_DEBUG "${OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_DEBUG}"
)
