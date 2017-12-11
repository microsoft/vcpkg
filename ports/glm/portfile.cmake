include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF 0.9.8.5
    SHA512 5a7e84ecc5a54320c74776c133bfdbeaf0d4496a7a7fdf2f4ccf89e66b3665a577a370a662ac97a350a2b1f717ce769cb0826057ebb3b13c9c2fee65f20ac7b4
    HEAD_REF master
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
file(COPY ${SOURCE_PATH}/copying.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glm/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glm/copying.txt ${CURRENT_PACKAGES_DIR}/share/glm/copyright)
