include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 579f51f5b30197386ccadcf0f3e0a3159ef3602f
    SHA512 89cd5c86d04bc393180846c10e1122d01cd4d3ad041ca7e9199341bdc758903edf7b892a424a3b90aa2753bfede230ff3434cefd7f2fefefafa7959f5b8660d4
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Tools
file(INSTALL ${SOURCE_PATH}/Tools/CppMerge.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/vlpp RENAME copyright)
