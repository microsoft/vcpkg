vcpkg_fail_port_install(ON_TARGET UWP)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fail_port_install(ON_ARCH arm arm64)
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO capnproto/capnproto
    REF 57a4ca5af5a7f55b768a9d9d6655250bffb1257f # v0.8.0
    SHA512 6550356a40a13d41fbeef3887027de1134c4bc37e4d79435e67da1f65665f3856f7cd663be392135cf4a08fffcfd4e171614026c20bfc5727adfd624b2d33e35
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/CapnProto)

vcpkg_copy_tools(TOOL_NAMES capnp capnpc-c++ capnpc-capnp AUTO_CLEAN)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
