vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF 3.16.01
    SHA512 c5c4b6637da5257e6dbbccd293a07691d509bf1310a67aa8b85777a1163f0034874e0638728a54deaa0839320fd919b67a8c9e22461fee6612a76637bb3086bc
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
