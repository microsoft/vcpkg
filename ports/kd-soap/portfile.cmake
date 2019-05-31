include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDSoap
    REF 7585cce5cb516f64ae89a962c3856fb456bd50f2
    SHA512 6e2b9e39e2c23fdf0434d4d9bd1e852dde1fc0afa51ad2db889bdcd5c4a6f444b8e1d88bb00b9a5adda9af41b9662cb34fdf2a749f2e5481d472dd56f9bada6f
    HEAD_REF master
)
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/8236bd7424-79789c62ed
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/kd-saop.patch"
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/kd-soap RENAME copyright)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kdwsdl2cpp.exe ${CURRENT_PACKAGES_DIR}/tools/kdwsdl2cpp.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kdwsdl2cpp.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
