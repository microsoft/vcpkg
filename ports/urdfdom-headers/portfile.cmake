vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/urdfdom_headers
    REF a15d906ff16a7fcbf037687b9c63b946c0cc04a1 # 1.0.5
    SHA512 794acd3b077a1d8fa27d0a698cecbce42f3a7b30f867e79b9897b0d97dcd9e80d2cf3b0c75ee34f628f73afb871c439fffe4a1d7ed85c7fac6553fb1e5b56c36
    HEAD_REF master
    PATCHES fix-include-path.patch
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

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
    vcpkg_fixup_pkgconfig()
endif()

# The config files for this project use underscore
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/urdfdom-headers ${CURRENT_PACKAGES_DIR}/share/urdfdom_headers)
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
