include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/http-parser
    REF v2.9.2
    SHA512 fe21ba46c9297b55a6382497b689da2af88999a9a5716ffef0731057ce1bb053056e4f20147284c78338e48ed1a793a0270fe0edfe3f4b589926e3ede603d023
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
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-http-parser TARGET_PATH share/unofficial-http-parser)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE-MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/http-parser)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/http-parser/LICENSE-MIT ${CURRENT_PACKAGES_DIR}/share/http-parser/copyright)
