#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cbeck88/visit_struct
    REF v1.0
    SHA512 1396d0d4c4d37f48434361d1e0ab4cb02c397aff1134678b26de713a27a4fcfa1c352890845502be645ba01e20314bf67731893fc6410b93e4521c1261d63c06
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/visit_struct TARGET_PATH share/visit_struct)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
