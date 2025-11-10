vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EmmyLua/EmmyLuaDebugger
    REF 1.8.7
    SHA512 d697d0ea12ca24c4f692e8104f75f681b7c56635459f6af437064e0e45b5b1cde5480817a7bd2de98555ffe6ef42712c3797e7dfd807425bfa095e0780a8fb5e
    HEAD_REF master
)

# Check features to determine Lua version
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        luajit USE_LUAJIT
)

# Set Lua version based on features
if("luajit" IN_LIST FEATURES)
    set(EMMY_LUA_VERSION_OPTION "-DEMMY_LUA_VERSION=jit")
else()
    # Default to Lua 5.4
    set(EMMY_LUA_VERSION_OPTION "-DEMMY_LUA_VERSION=54")
endif()

# Set policies for Windows-specific issues and tool port configuration
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)

# Skip CMake config checks for tool ports - emmylua-debugger doesn't export CMake configs
# Any detected CMake files are from dependencies, not the port itself
set(VCPKG_POLICY_SKIP_MISPLACED_CMAKE_FILES_CHECK enabled)
set(VCPKG_POLICY_SKIP_LIB_CMAKE_MERGE_CHECK enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${EMMY_LUA_VERSION_OPTION}
)

vcpkg_cmake_install()

# Copy tools if they exist (Windows-specific - emmy_tool is only built on Windows)
if(VCPKG_TARGET_IS_WINDOWS AND EXISTS "${CURRENT_PACKAGES_DIR}/bin/emmy_tool${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(TOOL_NAMES emmy_tool AUTO_CLEAN)
endif()

# emmylua-debugger is primarily a tool port and does not generate CMake config files

# Install includes if they exist
if(EXISTS "${SOURCE_PATH}/include")
    file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endif()

# Remove debug includes and unwanted debug share
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install usage documentation if it exists
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/usage")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/copyright")

# Fix pkg-config files if present
vcpkg_fixup_pkgconfig()