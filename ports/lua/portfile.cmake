vcpkg_download_distfile(ARCHIVE
    URLS "https://www.lua.org/ftp/lua-${VERSION}.tar.gz"
    FILENAME "lua-${VERSION}.tar.gz"
    SHA512 3253d2cdc929da6438095a30d66ef16a1abdbb0ada8fee238705b3b38492f14be9553640fdca6b25661e01155ba5582032e0a2ef064e4c283e85efc0a128cabe
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        vs2015-impl-c99.patch
        fix-ios-system.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CMakeLists-cpp.txt" DESTINATION "${SOURCE_PATH}/cpp" RENAME "CMakeLists.txt")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cpp COMPILE_AS_CPP # Also used in cmake wrapper
    tools INSTALL_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
         ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-lua CONFIG_PATH share/unofficial-lua)

if("cpp" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-lua-cpp CONFIG_PATH "share/unofficial-lua-cpp")
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES lua luac SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/luaconf.h" "defined(LUA_BUILD_AS_DLL)" "1")
    endif()
endif()

# Suitable for old version
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in"  "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
