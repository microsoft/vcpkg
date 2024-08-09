
vcpkg_download_distfile(
    ARCHIVE
    URLS "https://www.lua.org/ftp/lua-${VERSION}.tar.gz"
    FILENAME "lua-${VERSION}.tar.gz"
    SHA512 4f9516acc4659dfd0a9e911bfa00c0788f0ad9348e5724fe8fb17aac59e9c0060a64378f82be86f8534e49c6c013e7488ad17321bafcc787831d3d67406bd0f4
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        vs2015-impl-c99.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/cpp/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/cpp")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    cpp COMPILE_AS_CPP
    tools INSTALL_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DLUA_RELEASE_VERSION=${VERSION}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-lua CONFIG_PATH share/unofficial-lua)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if (VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/luaconf.h" "defined(LUA_BUILD_AS_DLL)" "1")
    endif()
endif()

if ("cpp" IN_LIST FEATURES)
    set(LUA_PORT_CPP_USAGE_MESSAGE "target_link_libraries(main PRIVATE unofficial::lua::lua-cpp)")
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES lua luac SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    string(APPEND LUA_PORT_TOOLS_USAGE_MESSAGE
        "CMake can drive program execution with targets:\n"
        "  unofficial::lua::lua-compiler\n"
        "  unofficial::lua::lua-interpreter\n\n"
        "  add_custom_command(...\n"
        "      COMMAND \$<TARGET_FILE:unofficial::lua::lua-interpreter> ...\n"
        "      ...\n"
        "  )\n"
    )
endif()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
    @ONLY
)

# Handle post-build CMake instructions
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake"
    @ONLY
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/COPYRIGHT")
