include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/urdfdom_headers
    REF 1.0.0
    SHA512 b1f63c1a13f062c987d6be4fcea5eea903577a710d44fdce077722b70d72eb65a265131beac1fdeba576bde189ebf51ac0eb19b2b06a34b0f9fb9dcbd437291a
    HEAD_REF master
  )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")

# The config files for this project use underscore
file(RENAME ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers ${CURRENT_PACKAGES_DIR}/share/urdfdom_headers)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers RENAME copyright)
