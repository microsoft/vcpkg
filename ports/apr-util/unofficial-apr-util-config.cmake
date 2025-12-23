include(CMakeFindDependencyMacro)

# apr-util doesn't provide official CMake config files yet
# Create an interface target that wraps the library

find_library(APRUTIL_LIBRARY_RELEASE
    NAMES aprutil-1 libaprutil-1
    PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib
    NO_DEFAULT_PATH
)

find_library(APRUTIL_LIBRARY_DEBUG
    NAMES aprutil-1 libaprutil-1 aprutil-1d libaprutil-1d
    PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib
    NO_DEFAULT_PATH
)

find_path(APRUTIL_INCLUDE_DIR
    NAMES apu.h
    PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include
    NO_DEFAULT_PATH
)

if(NOT TARGET unofficial::apr::aprutil)
    add_library(unofficial::apr::aprutil UNKNOWN IMPORTED)
    
    if(APRUTIL_LIBRARY_RELEASE)
        set_property(TARGET unofficial::apr::aprutil APPEND PROPERTY
            IMPORTED_CONFIGURATIONS RELEASE
        )
        set_target_properties(unofficial::apr::aprutil PROPERTIES
            IMPORTED_LOCATION_RELEASE "${APRUTIL_LIBRARY_RELEASE}"
        )
    endif()
    
    if(APRUTIL_LIBRARY_DEBUG)
        set_property(TARGET unofficial::apr::aprutil APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG
        )
        set_target_properties(unofficial::apr::aprutil PROPERTIES
            IMPORTED_LOCATION_DEBUG "${APRUTIL_LIBRARY_DEBUG}"
        )
    endif()
    
    set_target_properties(unofficial::apr::aprutil PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${APRUTIL_INCLUDE_DIR}"
    )
    
    # Link against apr
    find_dependency(apr CONFIG REQUIRED)
    if(TARGET apr::apr-1)
        target_link_libraries(unofficial::apr::aprutil INTERFACE apr::apr-1)
    elseif(TARGET apr::libapr-1)
        target_link_libraries(unofficial::apr::aprutil INTERFACE apr::libapr-1)
    endif()
    
    # Link against expat (required dependency)
    find_dependency(expat CONFIG REQUIRED)
    target_link_libraries(unofficial::apr::aprutil INTERFACE expat::expat)
endif()
