include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF 0.9.9.5
    SHA512 3b329acf5144aab1c0f47f8045d34e097699bd6685118ad8322c5ce23afdcb44ba2bb07e49301db06355b8eef7d4340b72251d55e113b533740d1e6ef6609911
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/disable_warnings_as_error.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/glm")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/manual.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/glm/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glm/manual.md ${CURRENT_PACKAGES_DIR}/share/glm/copyright)
