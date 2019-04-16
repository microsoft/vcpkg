include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppgraphqlgen
    REF v2.1.0
    SHA512 6fdeade25fc5c4af18d0288b80044a94cc9dcba9eed1640ec2cce06741b874f027930761964ed72073a25e083c0cf2fb828b9cf9732099c8a4f185776b1e1b8a
    HEAD_REF master
    PATCHES
    bigobj.patch
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
