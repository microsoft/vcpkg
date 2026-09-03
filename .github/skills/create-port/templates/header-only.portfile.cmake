vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO {{GITHUB_REPO}}
    REF "{{VERSION}}"
    SHA512 {{SHA512_PLACEHOLDER}}
    HEAD_REF {{HEAD_REF}}
)

# For header-only libraries, we just need to install the headers
file(INSTALL 
    "${SOURCE_PATH}/{{INCLUDE_DIR}}"
    DESTINATION "${CURRENT_PACKAGES_DIR}"
    PATTERN "*.hpp"
    PATTERN "*.h"
    PATTERN "*.hxx"
)

# Create a CMake config file for easy consumption
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" "
include(CMakeFindDependencyMacro)

# Add any dependencies here
# find_dependency(dependency1)
# find_dependency(dependency2)

# Use find_path to locate the main header
find_path({{PACKAGE_NAME_UPPER}}_INCLUDE_DIR
    NAMES {{MAIN_HEADER_FILE}}
    PATHS \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
    NO_DEFAULT_PATH
)

# Create the target using unofficial namespace (required by vcpkg guidelines)
add_library(unofficial::${PORT} INTERFACE IMPORTED)
set_target_properties(unofficial::${PORT} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${{{PACKAGE_NAME_UPPER}}_INCLUDE_DIR}"
)

# For backwards compatibility
add_library(${PORT} INTERFACE IMPORTED)
set_target_properties(${PORT} PROPERTIES
    INTERFACE_LINK_LIBRARIES unofficial::${PORT}
)

# Set variables for find_package compatibility
set({{PACKAGE_NAME_UPPER}}_FOUND TRUE)
set({{PACKAGE_NAME_UPPER}}_INCLUDE_DIRS \"\${{{PACKAGE_NAME_UPPER}}_INCLUDE_DIR}\")
")

# Install usage instructions
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Install copyright/license file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/{{LICENSE_FILE}}")
