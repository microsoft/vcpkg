# Portfile for Kendez.NikSms C++ SDK
# Version: 1.2.0

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drkeivanmirzaei/Kendez.Niksms.SDK.CPlus
    REF v1.2.0
    SHA512 0  # Will be updated when the repository is created
    HEAD_REF main
)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Configure CMake
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
    OPTIONS_DEBUG
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

# Build the library
vcpkg_cmake_build()

# Install the library
vcpkg_cmake_install()

# Copy CMake config files
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "KendezNiksmsSDK"
    CONFIG_PATH "lib/cmake/KendezNiksmsSDK"
)

# Copy pkg-config files if they exist
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    vcpkg_fixup_pkgconfig()
endif()

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Create usage file
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" 
"# Kendez.NikSms C++ SDK

## Usage

\`\`\`cmake
find_package(KendezNiksmsSDK CONFIG REQUIRED)
target_link_libraries(your_target KendezNiksmsSDK)
\`\`\`

## Features

- REST API client
- gRPC client (optional)
- Modern C++17
- Cross-platform support

## Examples

See the examples directory for usage examples.

## Documentation

Visit https://webservice.niksms.com for full documentation.
")

# Create vcpkg.json for the installed package
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg.json"
"{
  \"name\": \"kendez-niksms-sdk\",
  \"version\": \"1.2.0\",
  \"description\": \"C++ SDK for Kendez.NikSms SMS Web Service (REST & gRPC)\",
  \"homepage\": \"https://webservice.niksms.com\",
  \"license\": \"MIT\",
  \"supports\": \"windows & linux & osx\",
  \"dependencies\": [
    \"curl\",
    \"grpc\",
    \"protobuf\",
    \"nlohmann-json\"
  ]
}
")
