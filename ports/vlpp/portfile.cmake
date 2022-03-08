vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 1.1.0.0
    SHA512 b1526477bb05f0640d00a11bc6c281b98b790188c90e252a886e2699e5e9cb972ef0622a9085e2c035d943d8cbb2a4321fa9e91cf1daa390a7dcb87dfb94c162
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Tools
file(INSTALL "${SOURCE_PATH}/Tools/CppMerge.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/vlpp" RENAME copyright)
