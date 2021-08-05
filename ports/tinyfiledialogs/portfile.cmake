vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tinyfiledialogs
    SHA512 d63d6dd847d6bbd1f252c8fbd228086381af7189ac71afc97bd57e06badd1d3f4d90c6aab6207191ae7253d5a71fc44636cf8e33714089d5b478dd2714f59376
    FILENAME "tinyfiledialogs-current.zip"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
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
