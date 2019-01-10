include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppgraphqlgen
    REF v1.0.0
    SHA512 3756c31063dc86d1c37d3cb709221b2b6e7dda5f3405d7586e4f395fd4915b1088c0305b116164c615846413042857fd688e61ef36c5c2aab218cfab8f16370c
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
