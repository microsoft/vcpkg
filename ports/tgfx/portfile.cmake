vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/Tencent/tgfx.git
    REF feature/skyrimHuang_vcpkg
    PATCHES
        add-vcpkg-install.patch
)

# Sync third-party dependencies using depsync tool
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    # For macOS platform: run sync_deps.sh script
    vcpkg_execute_required_process(
        COMMAND "${SOURCE_PATH}/sync_deps.sh"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME sync-deps
    )
else()
    # For other platforms: use depsync tool
    # First install depsync globally
    vcpkg_execute_required_process(
        COMMAND npm install -g depsync
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME install-depsync
    )
    
    # Then run depsync in project root
    vcpkg_execute_required_process(
        COMMAND depsync
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME run-depsync
    )
endif()

# Handle feature flags - respect CMakeLists.txt defaults
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        # Features that default to OFF in CMakeLists.txt
        svg             TGFX_BUILD_SVG
        layers          TGFX_BUILD_LAYERS
        drawers         TGFX_BUILD_DRAWERS
        qt              TGFX_USE_QT
        swiftshader     TGFX_USE_SWIFTSHADER
        angle           TGFX_USE_ANGLE
        async-promise   TGFX_USE_ASYNC_PROMISE
    INVERTED_FEATURES
        # Features that default to ON in CMakeLists.txt
        # When not specified by user, these will be ON
        exclude-opengl          TGFX_USE_OPENGL
        exclude-faster-blur     TGFX_USE_FASTER_BLUR
)

# Fix include directories to use generator expressions for proper vcpkg installation
file(READ "${SOURCE_PATH}/CMakeLists.txt" CMAKELIST_CONTENT)

# Replace the existing target_include_directories to use generator expressions
string(REPLACE 
    "target_include_directories(tgfx PUBLIC include PRIVATE src)"
    "target_include_directories(tgfx PUBLIC \$<BUILD_INTERFACE:\${CMAKE_CURRENT_SOURCE_DIR}/include> \$<INSTALL_INTERFACE:include> PRIVATE src)"
    CMAKELIST_CONTENT "${CMAKELIST_CONTENT}")

# Replace drawers target_include_directories if it exists
string(REPLACE 
    "target_include_directories(tgfx-drawers PUBLIC drawers/include PRIVATE include drawers/src)"
    "target_include_directories(tgfx-drawers PUBLIC \$<BUILD_INTERFACE:\${CMAKE_CURRENT_SOURCE_DIR}/drawers/include> \$<INSTALL_INTERFACE:include> PRIVATE include drawers/src)"
    CMAKELIST_CONTENT "${CMAKELIST_CONTENT}")

file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${CMAKELIST_CONTENT}")


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTGFX_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DTGFX_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

# Fix CMake config and create proper targets
vcpkg_cmake_config_fixup(PACKAGE_NAME tgfx CONFIG_PATH share/tgfx)

# Remove debug headers (not needed for static library)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Install copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")