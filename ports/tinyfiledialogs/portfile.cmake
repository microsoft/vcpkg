vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH "${SOURCE_PATH}"
    URL "https://git.code.sf.net/p/tinyfiledialogs/code"
    REF "ab6f4f916aaa95d05247ffa66a30867e7f55e875"
)

file(COPY "${${SOURCE_PATH}}/tinyfiledialogs.h" "${${SOURCE_PATH}}/tinyfiledialogs.c" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()
file(INSTALL "${SOURCE_PATH}/tinyfiledialogs.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(READ "${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs/tinyfiledialogs.h" _contents)
string(SUBSTRING "${_contents}" 0 1024 _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${_contents}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs")
