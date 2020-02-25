include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cppgraphqlgen
    REF a70d822b5fa205e29c752fb0f8cc13bb010a47ea # v3.0.4
    SHA512 80111ba78382b833a67e8fe4d0db0023e7d16e21d8abb21f06a9248918ee1010f9cfd5433f1c82122a7d59d53a2dab88ef699d1a13054c6d3455370622e3d71c
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
