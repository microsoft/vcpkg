vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://git.code.sf.net/p/tinyfiledialogs/code"
    REF "8e966d92d0e772b5e34ffc3d8ec1559731a07ccb"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()
file(READ "${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs/tinyfiledialogs.h" _contents)
# reads between the line "- License -" and a closing "*/"
if (NOT _contents MATCHES [[- License -(([^*]|\*[^/])*)\*/]])
	message(FATAL_ERROR "Failed to parse license from tinyfiledialogs.h")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${CMAKE_MATCH_1}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
