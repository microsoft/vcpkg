vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/http-parser
    REF 2343fd6b5214b2ded2cdcf76de2bf60903bb90cd # v2.9.4
    SHA512 9fb95794d2c278c933e9bff0284befd1a8c8cf8ddda8e9929669f3134246d7fe81b54293359164d947f9278e2dd28b87d29a8ad8f523ed659d62713d782c7e46
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
