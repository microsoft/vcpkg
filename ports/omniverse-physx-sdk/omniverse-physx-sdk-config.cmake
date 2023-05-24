# omniverse-physx-sdk-config.cmake
# user CMakeLists.txt should:
# find_package(omniverse-physx-sdk CONFIG REQUIRED)
# target_link_libraries(main omniverse-physx-sdk::physx_sdk)

# Find include and library directories
get_filename_component(z_vcpkg_omniverse_physx_sdk_prefix "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(z_vcpkg_omniverse_physx_sdk_prefix "${z_vcpkg_omniverse_physx_sdk_prefix}" PATH)
get_filename_component(z_vcpkg_omniverse_physx_sdk_prefix "${z_vcpkg_omniverse_physx_sdk_prefix}" PATH)

get_filename_component(OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS "${z_vcpkg_omniverse_physx_sdk_prefix}/include/physx" ABSOLUTE)
get_filename_component(OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR "${z_vcpkg_omniverse_physx_sdk_prefix}/lib" ABSOLUTE)
get_filename_component(OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR "${z_vcpkg_omniverse_physx_sdk_prefix}/debug/lib" ABSOLUTE)

message(WARNING "just found all of the include, release libs dir and debug libs dir: ${OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS} and ${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR} and ${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}")

# Find library files
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

set_target_properties(omniverse-physx-sdk PROPERTIES
    IMPORTED_LOCATION_RELEASE "${OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE}"
    IMPORTED_LOCATION_DEBUG "${OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG}"
    INTERFACE_INCLUDE_DIRECTORIES "${OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS}"
)

message(WARNING "set_target_properties with IMPORTED_LOCATION_RELEASE ${OMNIVERSE-PHYSX-SDK_LIBRARY_RELEASE} IMPORTED_LOCATION_DEBUG ${OMNIVERSE-PHYSX-SDK_LIBRARY_DEBUG} INTERFACE_INCLUDE_DIRECTORIES ${OMNIVERSE-PHYSX-SDK_INCLUDE_DIRS}")

if(WIN32 AND VCPKG_CRT_LINKAGE STREQUAL "static")
    set_target_properties(omniverse-physx-sdk PROPERTIES
        INTERFACE_COMPILE_OPTIONS "/MT$<$<CONFIG:Debug>:d>"
    )
elseif(WIN32 AND VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set_target_properties(omniverse-physx-sdk PROPERTIES
        INTERFACE_COMPILE_OPTIONS "/MD$<$<CONFIG:Debug>:d>"
    )
endif()

message(WARNING "all right, target created and set with linkage ${VCPKG_LIBRARY_LINKAGE} and crt linkage ${VCPKG_CRT_LINKAGE}")

if (WIN32)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(WARNING "---------------- YEAH GOING FOR DYNAMIC LIBS!")
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
        message(WARNING "---------------- YEAH GOING FOR STATIC LIBS!")
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
    # Make sure the next CMake targets after this file will have the correct multi-threaded
    # statically-linked runtime library (either debug or release) as required by PhysX
    # message("Setting CMAKE_MSVC_RUNTIME_LIBRARY to multi-threaded statically-linked runtime for next targets")
    # set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
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

# ...

# Prepare the full paths of the libraries
if (WIN32)
    # ...
    foreach(lib ${OMNIVERSE-PHYSX-SDK_LIBRARIES})
        find_library(full_path_of_${lib}_RELEASE NAMES ${lib} PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
        find_library(full_path_of_${lib}_DEBUG NAMES ${lib} PATHS "${OMNIVERSE-PHYSX-SDK_DEBUG_LIBS_DIR}" NO_DEFAULT_PATH)
        add_library(${lib} UNKNOWN IMPORTED)
        set_target_properties(${lib} PROPERTIES
            IMPORTED_LOCATION_RELEASE "${full_path_of_${lib}_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${full_path_of_${lib}_DEBUG}"
        )
        list(APPEND full_paths_of_libraries "${lib}")
    endforeach()
elseif(UNIX)
    # ...
    foreach(lib ${OMNIVERSE-PHYSX-SDK_LIBRARIES})
        find_library(full_path_of_${lib} NAMES ${lib} PATHS "${OMNIVERSE-PHYSX-SDK_RELEASE_LIBS_DIR}" NO_DEFAULT_PATH)
        #message(WARNING "  --analyzing ${lib}.. imported location: ${full_path_of_${lib}}")
        add_library(${lib} UNKNOWN IMPORTED)
        # When CMake will link against this lib target, it will use this absolute path
        set_target_properties(${lib} PROPERTIES
            IMPORTED_LOCATION "${full_path_of_${lib}}"
        )
        list(APPEND full_paths_of_libraries "${lib}")
    endforeach()
endif()

message(WARNING "full_paths_of_libraries is set to ${full_paths_of_libraries}")

# Link the libraries to the target
# TODO: make sure INTERFACE is the right one. I.e. whoever links with this target, will also link with all these libs, but the main library will NOT link against these (it doesn't depend on them).
target_link_libraries(omniverse-physx-sdk INTERFACE ${full_paths_of_libraries})

# ...
