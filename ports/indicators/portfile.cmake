# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/indicators
    REF a938eb8f4c7e6436e3d9be16dc0169992bffb7ca
    SHA512 f221997e23b53b13b3e8fec72d6f73d658a584428ec1377e5aa5b72a7441bb82af9182c02c437e7f663e6de1b815421b2c3dba341e8984faf16c98a16f509ec6
    HEAD_REF master
    PATCHES
        0001-Improve-CMakeLists.txt.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/indica TARGET_PATH share/indica)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.termcolor DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
