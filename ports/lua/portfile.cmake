
vcpkg_download_distfile(
    ARCHIVE
    URLS "https://www.lua.org/ftp/lua-5.3.5.tar.gz"
    FILENAME "lua-5.3.5.tar.gz"
    SHA512 4f9516acc4659dfd0a9e911bfa00c0788f0ad9348e5724fe8fb17aac59e9c0060a64378f82be86f8534e49c6c013e7488ad17321bafcc787831d3d67406bd0f4
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES vs2015-impl-c99.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cpp/CMakeLists.txt DESTINATION ${SOURCE_PATH}/cpp)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    cpp COMPILE_AS_CPP
    tools INSTALL_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
        -DSKIP_INSTALL_TOOLS=ON
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-lua CONFIG_PATH share/unofficial-lua)

if ("tools" IN_LIST FEATURE_OPTIONS)
    vcpkg_copy_tools(TOOL_NAMES lua luac SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if (VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/luaconf.h" "defined(LUA_BUILD_AS_DLL)" "1")
    endif()
endif()

# Handle post-build CMake instructions
configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake
    @ONLY
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
