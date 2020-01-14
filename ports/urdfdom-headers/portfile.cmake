include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/urdfdom_headers
    REF 00c1c9c231e46b2300d04073ad696521758fa45c
    SHA512 8622cfad074454ae34be3e77c37b201adeb0e348df251e1c2fd57f35ae24817bbd2880a9c465056976eb8815fda041ba2fbd70ccb7cac6efc5ed3d7a082e80ef
    HEAD_REF master
  )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake TARGET_PATH share/urdfdom_headers)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/urdfdom_headers/cmake TARGET_PATH share/urdfdom_headers)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/urdfdom_headers)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/urdfdom_headers)
endif()

# The config files for this project use underscore
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers ${CURRENT_PACKAGES_DIR}/share/urdfdom_headers)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers RENAME copyright)
