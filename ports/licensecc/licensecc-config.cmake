# licensecc CMake configuration file for vcpkg

@PACKAGE_INIT@

include(CMakeFindDependencyMacro)

# Find OpenSSL dependency
find_dependency(OpenSSL REQUIRED)

# Import the static library target
if(NOT TARGET licensecc::licensecc_static)
    add_library(licensecc::licensecc_static STATIC IMPORTED)
    
    # Set the library file location
    find_library(LICENSECC_LIBRARY_RELEASE NAMES licensecc_static PATHS "${PACKAGE_PREFIX_DIR}/lib" NO_DEFAULT_PATH)
    find_library(LICENSECC_LIBRARY_DEBUG NAMES licensecc_static PATHS "${PACKAGE_PREFIX_DIR}/debug/lib" NO_DEFAULT_PATH)
    
    # Set library properties
    set_target_properties(licensecc::licensecc_static PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/include"
        INTERFACE_COMPILE_DEFINITIONS "HAS_OPENSSL"
        INTERFACE_LINK_LIBRARIES "OpenSSL::Crypto"
    )
    
    # Set the imported configurations
    if(LICENSECC_LIBRARY_RELEASE)
        set_property(TARGET licensecc::licensecc_static APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(licensecc::licensecc_static PROPERTIES IMPORTED_LOCATION_RELEASE "${LICENSECC_LIBRARY_RELEASE}")
    endif()
    if(LICENSECC_LIBRARY_DEBUG)
        set_property(TARGET licensecc::licensecc_static APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(licensecc::licensecc_static PROPERTIES IMPORTED_LOCATION_DEBUG "${LICENSECC_LIBRARY_DEBUG}")
    endif()
    
    # If no specific configuration is found, use the first available one
    if(NOT LICENSECC_LIBRARY_RELEASE AND NOT LICENSECC_LIBRARY_DEBUG)
        message(FATAL_ERROR "Could not find licensecc_static library")
    elseif(LICENSECC_LIBRARY_RELEASE)
        set_target_properties(licensecc::licensecc_static PROPERTIES IMPORTED_LOCATION "${LICENSECC_LIBRARY_RELEASE}")
    else()
        set_target_properties(licensecc::licensecc_static PROPERTIES IMPORTED_LOCATION "${LICENSECC_LIBRARY_DEBUG}")
    endif()
endif()

# Set found variables
set(licensecc_FOUND TRUE)
set(LICENSECC_FOUND TRUE)
