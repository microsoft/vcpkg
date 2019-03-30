include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/urdfdom_headers
    REF 1.0.2
    SHA512 902cf18b3ccc62dd5d732707e9ca2b8698f3307b8005d3858fcdd0e9585d580bbe5d2ec77c8c8bfa7b8776b870844368a8ec93b0f8a8d71420cf5015a99b8867
    HEAD_REF master
  )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake" TARGET_PATH share/urdfdom_headers)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/urdfdom_headers/cmake" TARGET_PATH share/urdfdom_headers)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/urdfdom_headers)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/urdfdom_headers)
endif()

# The config files for this project use underscore
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers ${CURRENT_PACKAGES_DIR}/share/urdfdom_headers)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers RENAME copyright)
