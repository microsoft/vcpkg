include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF 3.14.01
    SHA512 efc03bdd4b6371b3fb4b75cac31ce3081290e9177453914a4fbb601d1ba44d65a86f2e98b7b27efbd985f37bd59a80169cf58beb3a32e5b3672ea2a2d6dd78d1
    HEAD_REF master
    PATCHES 
    fix_cmake_install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DEASTL_BUILD_TESTS=OFF
    -DEASTL_BUILD_BENCHMARK=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/3RDPARTYLICENSES.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# CommonCppFlags used by EAThread
file(INSTALL ${SOURCE_PATH}/scripts/CMake/CommonCppFlags.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
