vcpkg_fail_port_install(ON_ARCH "x86" "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDNN
    REF v2.0
    SHA512 740fa871e29edc8bb8a54d4ba615e856712f7f63efe4c70f4a3d5f6d143d60bc51366b9355ab4b6702718ba711b48350ea49b1335ec10c1dc4f655cc9728ff3e
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(DNNL_OPTIONS "-DDNNL_LIBRARY_TYPE=STATIC")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${DNNL_OPTIONS}
)
vcpkg_install_cmake()

# The port name and the find_package() name are different (onednn versus dnnl)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/dnnl TARGET_PATH share/dnnl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Copyright and license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
