vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zrax/string_theory
    REF 3.3
    SHA512 86209333dce341078c3b973084bd9f3b8ff2ccac0e07a5e6acf5973bd1cfa420897b531b2d1bd6aba9f5ccc8927f85d91f06796ac0e62ec8a735564a0387d2f4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/string_theory)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/string-theory ${CURRENT_PACKAGES_DIR}/share/string_theory)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/string-theory)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/string-theory/LICENSE ${CURRENT_PACKAGES_DIR}/share/string-theory/copyright)
file(COPY ${CURRENT_PACKAGES_DIR}/share/string-theory/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/string_theory/copyright)
