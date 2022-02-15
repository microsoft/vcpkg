vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    FETCH_REF master
    HEAD_REF master
    URL https://git.code.sf.net/p/tinyfiledialogs/code
    REF e11f94cd7887b101d64f74892d769f0139b5e166
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs/tinyfiledialogs.h" _contents)
# reads between the line "- License -" and a closing "*/"
if (NOT _contents MATCHES [[- License -(([^*]|\*[^/])*)\*/]])
    message(FATAL_ERROR "Failed to parse license from tinyfiledialogs.h")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${CMAKE_MATCH_1}")
