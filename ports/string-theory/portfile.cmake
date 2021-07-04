vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zrax/string_theory
    REF 3.4
    SHA512 36ad82c6da276b7cb66d350ceb4bed2a66f768a6604b2981331ceec6a96d03cc3a7e7e5f733de88ec15e0ea41f99f8657b959a51149c540f530d06268c5657ff
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
