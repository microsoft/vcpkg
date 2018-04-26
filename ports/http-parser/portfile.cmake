include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/http-parser
    REF v2.7.1
    SHA512 c0fe86455db1a563a5c668f118dfa9a27b9a637ee1c0e2f2f18a5b816352436ed90435ea978e3f3d85b037d3c630234e47d609dc3b7086b898286c4e54d9f031
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
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/unofficial-http-parser" TARGET_PATH "share/unofficial-http-parser")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE-MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/http-parser)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/http-parser/LICENSE-MIT ${CURRENT_PACKAGES_DIR}/share/http-parser/copyright)
