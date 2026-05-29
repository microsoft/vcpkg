# omniverse-physx-sdk-config.cmake (from which unofficial-omniverse-physx-sdk-config.cmake is generated)
# A user's CMakeLists.txt should:
#   find_package(unofficial-omniverse-physx-sdk CONFIG REQUIRED)
#   target_link_libraries(main PRIVATE unofficial::omniverse-physx-sdk::sdk)
# the GPU acceleration .so/.dll libraries are in the port's tools/ directory (needed for late binding).
# See the usage file for more info and more detailed explanation on how to use this.

include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)

if(NOT TARGET unofficial::omniverse-physx-sdk)
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

    # Find main library files
    find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE NAMES PhysX_static_64 PhysX_64 PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
    find_library(OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG NAMES PhysX_static_64 PhysX_64 PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)

    # Finally create the imported target that users will link against
    set(OMNIVERSE-PHYSX-SDK_LIBRARIES "")
    add_library(unofficial::omniverse-physx-sdk::sdk UNKNOWN IMPORTED)

    # Set IMPORTED_IMPLIB for the main target in case of dynamic libraries
    if (WIN32 AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set_target_properties(unofficial::omniverse-physx-sdk::sdk PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE}"
            IMPORTED_IMPLIB_DEBUG "${OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG}"
        )
    endif()

    set_target_properties(unofficial::omniverse-physx-sdk::sdk PROPERTIES
        IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
        IMPORTED_LOCATION_RELEASE "${OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE}"
        IMPORTED_LOCATION_DEBUG "${OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG}"
        INTERFACE_INCLUDE_DIRECTORIES "${OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS}"
    )

    # Add compile definitions to the target for debug/release builds
    target_compile_definitions(unofficial::omniverse-physx-sdk::sdk INTERFACE $<$<CONFIG:Debug>:_DEBUG>)

    set(lib_names
            PhysXExtensions
            PhysXPvdSDK
            PhysXCharacterKinematic
            PhysXCooking
            PhysXCommon
            PhysXFoundation
            PhysXVehicle
    )
    if(WIN32)
        list(APPEND lib_names PhysXVehicle2)
    endif()

    foreach(name IN LISTS lib_names)
        find_library(OMNIVERSE_${name}_LIBRARY_RELEASE
            NAMES ${name}_static_64 ${name}_64 # ...  all candidates, only one should be installed for a given triplet
            PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}"
            NO_DEFAULT_PATH
            REQUIRED
        )
        find_library(OMNIVERSE_${name}_LIBRARY_DEBUG
            NAMES ${name}_static_64 ${name}_64 # ...  all candidates, only one should be installed for a given triplet
            PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}"
            NO_DEFAULT_PATH
            # not REQUIRED, due to release-only builds
        )
        add_library(unofficial::omniverse-physx-sdk::${name} UNKNOWN IMPORTED)
        set_target_properties(unofficial::omniverse-physx-sdk::${name}
            PROPERTIES
                IMPORTED_CONFIGURATIONS "RELEASE"
                IMPORTED_LOCATION_RELEASE "${OMNIVERSE_${name}_LIBRARY_RELEASE}"
        )
        if(OMNIVERSE_${name}_LIBRARY_DEBUG)
            set_target_properties(unofficial::omniverse-physx-sdk::${name}
                PROPERTIES
                    IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
                    IMPORTED_LOCATION_DEBUG "${OMNIVERSE_${name}_LIBRARY_DEBUG}"
            )
        endif()
        set_property(TARGET unofficial::omniverse-physx-sdk::sdk APPEND PROPERTY
            INTERFACE_LINK_LIBRARIES unofficial::omniverse-physx-sdk::${name}
        )
        select_library_configurations(OMNIVERSE_${name})
    endforeach()

    # Lastly also provide a target for clients to link with the GPU library (optional, provided by NVIDIA and downloaded through packman)

    # Find GPU library files (these are used at late-binding to enable GPU acceleration)
    if(WIN32)
        find_file(OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_RELEASE NAMES PhysXGpu_64.dll PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_TOOLS_DIR}" NO_DEFAULT_PATH)
        find_file(OMNIVERSE-PHYSX-SDK-GPU_DEVICE_LIBRARY_RELEASE NAMES PhysXDevice64.dll PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_TOOLS_DIR}" NO_DEFAULT_PATH)
    elseif(UNIX)
        find_file(OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_RELEASE NAMES libPhysXGpu_64.so PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_TOOLS_DIR}" NO_DEFAULT_PATH)
    endif()

    # Create imported targets for GPU library (only release is used)
    add_library(unofficial::omniverse-physx-sdk::gpu-library SHARED IMPORTED)
    set_target_properties(unofficial::omniverse-physx-sdk::gpu-library PROPERTIES
        IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
        IMPORTED_LOCATION "${OMNIVERSE-PHYSX-SDK-GPU_LIBRARY_RELEASE}"
    )
    if(WIN32)
        add_library(unofficial::omniverse-physx-sdk::gpu-device-library SHARED IMPORTED)
        set_target_properties(unofficial::omniverse-physx-sdk::gpu-device-library PROPERTIES
            IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
            IMPORTED_LOCATION "${OMNIVERSE-PHYSX-SDK-GPU_DEVICE_LIBRARY_RELEASE}"
        )
    endif()
endif()
