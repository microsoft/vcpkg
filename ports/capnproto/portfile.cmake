if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP build is not supported.")
endif()

include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO capnproto/capnproto
    REF v0.7.0
    SHA512 a3ea278ded6a866759c0517d16b99bd38ffea1c163ce63a3604b752d8bdaafbc38a600de94afe12db35e7f7f06e29cc94c911dc2e0ecec6fe1185452df2a2bd3
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
