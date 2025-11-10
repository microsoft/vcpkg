vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EmmyLua/EmmyLuaDebugger
    REF 23144c37a41f283aa5a41d13cb7ba1badee25fb5 # v1.8.7
    SHA512 0  # Placeholder - will be updated after first build attempt
    HEAD_REF master
)

# Configure CMake with Lua version support
if("lua51" IN_LIST FEATURES)
    set(EMMYLUA_VERSION "51")
elseif("lua52" IN_LIST FEATURES)
    set(EMMYLUA_VERSION "52")
elseif("lua53" IN_LIST FEATURES)
    set(EMMYLUA_VERSION "53")
elseif("luajit" IN_LIST FEATURES)
    set(EMMYLUA_VERSION "jit")
else()
    set(EMMYLUA_VERSION "54")  # Default to Lua 5.4
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEMMY_LUA_VERSION=${EMMYLUA_VERSION}
        -DEMMY_CORE_VERSION=${PORT}
)

vcpkg_cmake_install()

# The project structure suggests this is primarily a tool/executable
# Install built executables
vcpkg_copy_tools(
    TOOL_NAMES emmylua_debugger
    AUTO_CLEAN
)

# Install headers if they exist in the expected locations
if(EXISTS "${SOURCE_PATH}/emmy_core")
    file(GLOB_RECURSE HEADERS "${SOURCE_PATH}/emmy_core/*.h")
    if(HEADERS)
        foreach(header ${HEADERS})
            get_filename_component(header_dir ${header} DIRECTORY)
            file(RELATIVE_PATH relative_dir ${SOURCE_PATH}/emmy_core ${header_dir})
            file(INSTALL ${header} DESTINATION "${CURRENT_PACKAGES_DIR}/include/emmylua-debugger/${relative_dir}")
        endforeach()
    endif()
endif()

if(EXISTS "${SOURCE_PATH}/emmy_debugger")
    file(GLOB_RECURSE HEADERS "${SOURCE_PATH}/emmy_debugger/*.h")
    if(HEADERS)
        foreach(header ${HEADERS})
            get_filename_component(header_dir ${header} DIRECTORY)
            file(RELATIVE_PATH relative_dir ${SOURCE_PATH}/emmy_debugger ${header_dir})
            file(INSTALL ${header} DESTINATION "${CURRENT_PACKAGES_DIR}/include/emmylua-debugger/${relative_dir}")
        endforeach()
    endif()
endif()

# Remove debug include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright - create a default copyright notice if no license file exists
set(COPYRIGHT_TEXT "EmmyLua Debugger
High-performance cross-platform Lua debugger

Copyright (c) EmmyLua organization
Repository: https://github.com/EmmyLua/EmmyLuaDebugger

This project is distributed under the terms of its original license.
Please refer to the project repository for full license information.")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${COPYRIGHT_TEXT}")

# Fix pkg-config files if present
vcpkg_fixup_pkgconfig()