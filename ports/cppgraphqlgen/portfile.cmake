include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppgraphqlgen
    REF v0.7
    SHA512 503c3fdd7d5aed32acaeacc5b3be26ec795cd58948229a83c62740938833384166aa750980a305da7f2b19294726d0b19b95bf8e4d4889a40293185469703012
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_TESTS=OFF -DUPDATE_SAMPLES=OFF
    OPTIONS_RELEASE -DCMAKE_INSTALL_CONFIGDIR=${CURRENT_PACKAGES_DIR}/share/cppgraphqlgen -DCMAKE_INSTALL_TOOLSDIR=${CURRENT_PACKAGES_DIR}/tools/cppgraphqlgen
    OPTIONS_DEBUG -DCMAKE_INSTALL_CONFIGDIR=${CURRENT_PACKAGES_DIR}/debug/share/cppgraphqlgen -DCMAKE_INSTALL_TOOLSDIR=${CURRENT_PACKAGES_DIR}/debug/tools/cppgraphqlgen
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppgraphqlgen/copyright COPYONLY)

vcpkg_test_cmake(PACKAGE_NAME cppgraphqlgen)
