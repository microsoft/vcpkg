vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-license-manager/licensecc
    REF v2.0.0
    SHA512 4f1e80b536f2bb9685ac71fd185b841d0dfc0ef6747dac956d7514f7a3f207dfd366b87a7a6a505b8becf68660254eafbc26e8552ad34cd75c0530fae469bbaa
)

vcpkg_from_github(
    OUT_SOURCE_PATH LCC_GENERATOR_PATH
    REPO open-license-manager/lcc-license-generator
    REF HEAD
    SHA512 fc7b49075ca4f72fac0bf3ea3303c51afc03c976c5058ecb97cbe8bbf3319ab642489be8817048850ef88d89062efb6e01c7133a02f7f187f7fbdfbd860eb55a
)

file(REMOVE_RECURSE "${SOURCE_PATH}/extern/license-generator")
file(RENAME "${LCC_GENERATOR_PATH}" "${SOURCE_PATH}/extern/license-generator")

# Apply patches after setting up license-generator
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        fix-boost-filesystem-normalize.patch
        fix-include-path.patch
)

# Manually fix the CMakeLists.txt to remove project_initialize dependency
vcpkg_replace_string(
    ${SOURCE_PATH}/CMakeLists.txt
    "add_custom_target(project_initialize
  COMMAND license_generator::lccgen project initialize -t \"\${PROJECT_SOURCE_DIR}/src/templates\" -n \"\${LCC_PROJECT_NAME}\" -p \"\${LCC_PROJECTS_BASE_DIR}\"
  COMMENT \"generating \${LCC_PROJECT_PUBLIC_KEY} and \${LCC_PROJECT_PRIVATE_KEY} if they don't already exist\"
  USES_TERMINAL
)"
    "# Dummy target to replace project_initialize for vcpkg builds
add_custom_target(project_initialize)"
)

# Create dummy public key for compilation
set(LCC_INCLUDE_DIR "${SOURCE_PATH}/projects/DEFAULT/include/licensecc/DEFAULT")
file(MAKE_DIRECTORY "${LCC_INCLUDE_DIR}")
file(WRITE "${LCC_INCLUDE_DIR}/public_key.h" 
"#ifndef PUBLIC_KEY_H_
#define PUBLIC_KEY_H_
#define PRODUCT_NAME \"DEFAULT\"
#define PUBLIC_KEY {0x30,0x82,0x01,0x22}
#define PUBLIC_KEY_LEN 4
#endif
")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TESTING=OFF
        -DLCC_LOCATION=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

vcpkg_cmake_install()

# Move library files to the correct location
file(GLOB RELEASE_LIBS "${CURRENT_PACKAGES_DIR}/licensecc/DEFAULT/*.lib")
file(GLOB DEBUG_LIBS "${CURRENT_PACKAGES_DIR}/debug/licensecc/DEFAULT/*.lib")

if(RELEASE_LIBS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY ${RELEASE_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

if(DEBUG_LIBS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY ${DEBUG_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

# Move licensecc_properties.h from DEFAULT subdirectory to main licensecc include directory
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/licensecc/DEFAULT/licensecc_properties.h")
    file(COPY "${CURRENT_PACKAGES_DIR}/include/licensecc/DEFAULT/licensecc_properties.h" 
         DESTINATION "${CURRENT_PACKAGES_DIR}/include/licensecc/")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include/licensecc/DEFAULT/licensecc_properties.h")
    file(COPY "${CURRENT_PACKAGES_DIR}/debug/include/licensecc/DEFAULT/licensecc_properties.h" 
         DESTINATION "${CURRENT_PACKAGES_DIR}/debug/include/licensecc/")
endif()

# Remove the original library directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/licensecc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/licensecc")

# Remove and replace the original CMake files with a simplified one
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/cmake")

# Install CMake config files using vcpkg's helper
include(CMakePackageConfigHelpers)

# Configure the package config file
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/licensecc-config.cmake"
    "${CURRENT_PACKAGES_DIR}/share/licensecc/licensecc-config.cmake"
    INSTALL_DESTINATION "share/licensecc"
)

# Copy the version file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/licensecc-config-version.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/licensecc")

# Remove debug binaries and includes (they are the same as release)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Remove unwanted tools from bin directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/licensecc RENAME copyright)
