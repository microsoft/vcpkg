include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF 874c8e5f09cb2fa73a0a1d6b56fb6691a3aa1144 # v3.2.1
    SHA512 7e3e7a6d61ef7bec3ce44604cde09259eb62f808d2d0236431e2a4b290e85241b359c88974c8b21a9b1baa6c92d714c5265721adb528cee29b894aca9c581c23
    HEAD_REF develop
    PATCHES fix-namespace.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sol2)

file(
    REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL ${SOURCE_PATH}/single/include/sol DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
