vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF 1cf6182218bec79ece0b91e762f507e8c027807c # 3.16.07
    SHA512 a0d140a6ff202eb9360a7cbb4ae59881458b628a7bc5ffb19864aba585fd0b02c7f7a2692df2e1c52aa58bc3c3471f27b365fa7770b7d84c038d24884db10b9b
    HEAD_REF master
    PATCHES 
    fix_cmake_install.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/EASTLConfig.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DEASTL_BUILD_TESTS=OFF
    -DEASTL_BUILD_BENCHMARK=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/EASTL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/3RDPARTYLICENSES.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# CommonCppFlags used by EAThread
file(INSTALL ${SOURCE_PATH}/scripts/CMake/CommonCppFlags.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
