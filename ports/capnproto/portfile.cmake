if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP build is not supported.")
endif()

include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO capnproto/capnproto
    REF 57a4ca5af5a7f55b768a9d9d6655250bffb1257f # v0.8.0
    SHA512 6550356a40a13d41fbeef3887027de1134c4bc37e4d79435e67da1f65665f3856f7cd663be392135cf4a08fffcfd4e171614026c20bfc5727adfd624b2d33e35
    HEAD_REF master
	PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-fix-capnpc-extension-handling-on-Windows.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/CapnProto)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/capnproto")
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/capnproto)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/capnproto)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/capnproto/LICENSE ${CURRENT_PACKAGES_DIR}/share/capnproto/copyright)

# Disabled for now, see #5630 and #5635
# vcpkg_test_cmake(PACKAGE_NAME CapnProto)
