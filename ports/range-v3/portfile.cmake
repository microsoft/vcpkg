include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ericniebler/range-v3
    REF c0a1924a3f30bff8c86086849245b6e7ba79b4dd
    SHA512 ce7ee4b268db98a21fc1210deb2bb79c6b18b1fc5ce7300d64c8b72b97979c9fb8137af910fe42711e3dc9c1405bbc1bc8a15f3223f9ef5ad8416950f4f1576e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRANGE_V3_TESTS=OFF
        -DRANGE_V3_EXAMPLES=OFF
        -DRANGE_V3_PERF=OFF
        -DRANGE_V3_HEADER_CHECKS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/range-v3)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/range-v3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3/copyright)
