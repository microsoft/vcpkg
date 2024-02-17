if(NOT WIN32)
    include(CMakeFindDependencyMacro)
    find_dependency(Threads)
endif()

if(NOT TARGET unofficial::libvhdi::libvhdi)
    add_library(unofficial::libvhdi::libvhdi UNKNOWN IMPORTED)

    set_target_properties(unofficial::libvhdi::libvhdi PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
    )

    if(NOT WIN32)
        set_target_properties(unofficial::libvhdi::libvhdi PROPERTIES
            INTERFACE_LINK_LIBRARIES Threads::Threads
        )
    endif()

    find_library(VCPKG_LIBVHDI_LIBRARY_RELEASE NAMES vhdi libvhdi PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBVHDI_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libvhdi::libvhdi APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libvhdi::libvhdi PROPERTIES IMPORTED_LOCATION_RELEASE "${VCPKG_LIBVHDI_LIBRARY_RELEASE}")
    endif()

    find_library(VCPKG_LIBVHDI_LIBRARY_DEBUG NAMES vhdi libvhdi PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBVHDI_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libvhdi::libvhdi APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libvhdi::libvhdi PROPERTIES IMPORTED_LOCATION_DEBUG "${VCPKG_LIBVHDI_LIBRARY_DEBUG}")
    endif()
endif()
