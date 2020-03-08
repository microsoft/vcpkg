include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cppgraphqlgen
    REF c286c837223069a41ba3130dbee42314fd48de66 # v3.1.0
    SHA512 57a0923655976c9749794f4e4b8bf5397cfc974cd373f9dabb60b208052bb85d27f063f9456a2d0270eab1e040450c410e906d897bd7318c23572ecce6b60b18
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DGRAPHQL_BUILD_TESTS=OFF -DGRAPHQL_UPDATE_SAMPLES=OFF
    OPTIONS_RELEASE -DGRAPHQL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share -DGRAPHQL_INSTALL_TOOLS_DIR=${CURRENT_PACKAGES_DIR}/tools
    OPTIONS_DEBUG -DGRAPHQL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share -DGRAPHQL_INSTALL_TOOLS_DIR=${CURRENT_PACKAGES_DIR}/debug/tools
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/cppgraphqlgen)

vcpkg_copy_pdbs()

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppgraphqlgen/copyright COPYONLY)

vcpkg_test_cmake(PACKAGE_NAME cppgraphqlgen)
