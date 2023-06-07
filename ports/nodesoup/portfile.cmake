vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO olvb/nodesoup
    REF 3158ad0
    SHA512 be98cd5a1106fb1b6e6cb6b880229f590c2d4c4cc176dcceb2e2226ff3f2344ccb4510fb3a0911e9329701af50f076ee2efb9a3afc9e985b4d9c3fb92c12102d
    HEAD_REF main
    PATCHES
      fix-cmakelists.patch
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/nodesoup-config.cmake.in"
   DESTINATION "${SOURCE_PATH}/"
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
    -DBUILD_DEMO=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME nodesoup CONFIG_PATH lib/cmake/nodesoup)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nodesoup/" RENAME copyright)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nodesoup/")
