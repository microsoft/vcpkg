#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF e26475e75b0a116de95ce710b573989008b82a57 # v3.2.0
    SHA512 dde9ea3fba74b69e9ddadce9f82eb9773a8aa92bcc266a8c4e7a4863f4bc22b4dc52b24b690e97ff5ff4c44d858eaa06c3bd64837274f90a1d93ebd646df5d64
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
file(INSTALL ${SOURCE_PATH}/include/sol DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
