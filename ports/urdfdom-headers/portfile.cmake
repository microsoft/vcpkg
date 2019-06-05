include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/urdfdom_headers
    REF 1.0.3
    SHA512 44b1ca9724a9ccd5d2ad51f61d36de19b9a893955ad5c3ecfa2356f6468a0ac140b8cd6fa2aa18c163b0fa8ba87e834358369d2470cd3dee474408113a30b7a0
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
