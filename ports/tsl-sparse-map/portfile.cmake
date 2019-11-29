include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/sparse-map
    REF v0.6.1
    SHA512 c77e7625a0ff13a538f1a8c96d3f70a178e9bedfb22592d6ca848e6d1e6b1566c9a216b2df68592c27308156b776677d52e0d75cf09254acb62f60a00a4bc054
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} 
     RENAME copyright
)
