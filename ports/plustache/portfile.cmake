vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mrtazz/plustache
    REF 3208529343e1858cfe504041be8c1fa0af0a59d1
    SHA512 8d9ae368b2f276da2faaf4e3b543fc7ded88ebd8fbe33544aa7d85765a38d085d4c31bb68f6a2f73d4f660da1618d187fb94c74a5f6594e7642bf3949707c67b
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

#Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/plustache)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/plustache/LICENSE ${CURRENT_PACKAGES_DIR}/share/plustache/copyright)
