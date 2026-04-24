vcpkg_download_distfile(ARCHIVE
    URLS "{{DOWNLOAD_URL}}"
    FILENAME "{{PACKAGE_NAME}}-{{VERSION}}.tar.gz"
    SHA512 {{SHA512_PLACEHOLDER}}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    # Uncomment if patches are needed
    # PATCHES
    #     fix-makefile.patch
    #     fix-install.patch
)

# For autotools-based projects
if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            --disable-examples
            --disable-tests
            {{CONFIGURE_OPTIONS}}
    )
    
    vcpkg_install_make()
else()
    # Custom Windows build process
    vcpkg_execute_build_process(
        COMMAND ${CMAKE_COMMAND} -E env "CC=cl" "CXX=cl" make
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME build-${TARGET_TRIPLET}
    )
    
    # Manual installation for Windows
    file(INSTALL 
        "${SOURCE_PATH}/{{LIBRARY_PATH}}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    )
    file(INSTALL
        "${SOURCE_PATH}/{{HEADER_PATH}}"  
        DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    )
    
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL
            "${SOURCE_PATH}/{{DEBUG_LIBRARY_PATH}}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )
    endif()
endif()

# Create CMake config files manually since this package doesn't provide them
# Note: Use unofficial namespace as required by vcpkg guidelines
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" "
include(CMakeFindDependencyMacro)

# Add any dependencies here
# find_dependency(dependency1)

# Create the target using unofficial namespace
add_library(unofficial::${PORT} {{LIBRARY_TYPE}} IMPORTED)
set_target_properties(unofficial::${PORT} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
    IMPORTED_LOCATION \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/{{LIBRARY_NAME}}\"
)

# For backwards compatibility
add_library(${PORT} {{LIBRARY_TYPE}} IMPORTED)
set_target_properties(${PORT} PROPERTIES
    INTERFACE_LINK_LIBRARIES unofficial::${PORT}
)
")

# Install usage instructions
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Install copyright/license file  
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/{{LICENSE_FILE}}")

# Remove unwanted files
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)