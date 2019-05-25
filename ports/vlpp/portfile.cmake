include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 579f51f5b30197386ccadcf0f3e0a3159ef3602f
    SHA512 e738661d7613d46746121af34657fbbf46808923d75a4c3c62d0a6e7e010dc2f50d77d019835d07ffd5d1d897b06d199ab787a52b74aababc5ea11c8a67c4be4
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
