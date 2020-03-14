vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cppgraphqlgen
    REF v3.2.0
    SHA512 21b0ea4b7bcdfa8107018e3a53413f7242dfd3fe5f66c4c7f2b351b5aa7227281eb78b47462fae3e0ba203ad028e98d6d0ec6bbd93c90be56ab657007953e522
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
