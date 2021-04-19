vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(TINYFILEDIALOGS_VERSION "3.8.7")
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/tinyfiledialogs-${TINYFILEDIALOGS_VERSION}")

vcpkg_from_git(
    OUT_SOURCE_PATH "${SOURCE_PATH}"
    URL "https://git.code.sf.net/p/tinyfiledialogs/code"
    REF "ab6f4f916aaa95d05247ffa66a30867e7f55e875"
)

file(COPY "${${SOURCE_PATH}}/tinyfiledialogs.h" DESTINATION "${SOURCE_PATH}")
file(COPY "${${SOURCE_PATH}}/tinyfiledialogs.c" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs/tinyfiledialogs.h" _contents)
string(SUBSTRING "${_contents}" 0 1024 _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${_contents}")
