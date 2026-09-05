if(NOT TARGET unofficial::numa::numa)
    add_library(unofficial::numa::numa UNKNOWN IMPORTED)

    get_filename_component(Z_VCPKG_NUMA_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

    find_library(Z_VCPKG_NUMA_LIBRARY_RELEASE NAMES numa PATHS "${Z_VCPKG_NUMA_ROOT}/lib" NO_DEFAULT_PATH REQUIRED)
    find_library(Z_VCPKG_NUMA_LIBRARY_DEBUG NAMES numa PATHS "${Z_VCPKG_NUMA_ROOT}/debug/lib" NO_DEFAULT_PATH)

    if(Z_VCPKG_NUMA_LIBRARY_DEBUG)
        set_target_properties(unofficial::numa::numa PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Z_VCPKG_NUMA_ROOT}/include"
            IMPORTED_CONFIGURATIONS "Debug;Release"
            IMPORTED_LOCATION_DEBUG "${Z_VCPKG_NUMA_LIBRARY_DEBUG}"
            IMPORTED_LOCATION_RELEASE "${Z_VCPKG_NUMA_LIBRARY_RELEASE}"
        )
    else()
        set_target_properties(unofficial::numa::numa PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Z_VCPKG_NUMA_ROOT}/include"
            IMPORTED_CONFIGURATIONS "Release"
            IMPORTED_LOCATION_RELEASE "${Z_VCPKG_NUMA_LIBRARY_RELEASE}"
        )
    endif()

    unset(Z_VCPKG_NUMA_ROOT)
    unset(Z_VCPKG_NUMA_LIBRARY_RELEASE)
    unset(Z_VCPKG_NUMA_LIBRARY_DEBUG)
endif()
