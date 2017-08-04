include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF 0.9.8.4 
    SHA512 ff0e0651a695caebe9235882d14e09546d52b3cdf66cca8e2078f15b02a3fca4e47bd97d2807aa329f76aa633af3b4999501bd4d0b22ad44b00558d4917f39ed
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
