include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppgraphqlgen
    REF v2.0.1
    SHA512 c49b9caaa85352b30370532d36c9db5ac1d4dfc2d31befe99e2ee257c841ffe793760885d08e1929be39b7dfbc3bcdbd110c3033549e31ac1143974fb466e92b
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
